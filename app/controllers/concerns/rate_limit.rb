# typed: false
# frozen_string_literal: true

module RateLimit
  extend ActiveSupport::Concern

  DEFAULT_RETRY_AFTER = 60

  included do
    class_attribute :rate_limit_rules, instance_writer: false, default: []
    before_action :apply_rate_limit_rules
  end

  class_methods do
    def rate_limit_rule(name, scope:, limit:, period:, key: nil, retry_after: nil, only: nil, except: nil)
      only_actions = Array(only).compact
      only_actions.map!(&:to_s)
      except_actions = Array(except).compact
      except_actions.map!(&:to_s)

      rule = {
        name: name.to_s,
        scope: scope.to_s,
        limit: limit,
        period: period,
        key: key,
        retry_after: retry_after,
        only: only_actions,
        except: except_actions,
      }

      self.rate_limit_rules += [rule]
    end
  end

  def rate_limit!(rule:, key:, limit:, period:, retry_after: nil, scope: nil)
    count = rate_limit_store.increment(key, 1, expires_in: period)
    return if count.to_i <= limit

    throttle_rate_limit!(rule: rule, scope: scope, retry_after: retry_after || period || DEFAULT_RETRY_AFTER)
  rescue StandardError => e
    if RailsRateLimit.fail_close?
      Rails.logger.error(
        "[RailsRateLimit] STORE_ERROR mode=close rule=#{rule} scope=#{scope} " \
        "path=#{request.path} error=#{e.class}: #{e.message}",
      )
      throttle_rate_limit!(
        rule: "rate_limit_store_error",
        scope: scope || "store",
        retry_after: DEFAULT_RETRY_AFTER,
      )
    else
      Rails.logger.warn(
        "[RailsRateLimit] STORE_ERROR mode=open rule=#{rule} scope=#{scope} " \
        "path=#{request.path} error=#{e.class}: #{e.message}",
      )
    end
  end

  def rate_limit_key(rule:, tenant:, scope:, discriminator:)
    normalized_tenant = normalize_rate_limit_part(tenant)
    normalized_scope = normalize_rate_limit_part(scope)
    normalized_discriminator = normalize_rate_limit_part(discriminator)

    "#{rule}:#{normalized_tenant}:#{normalized_scope}:#{normalized_discriminator}"
  end

  private

  def apply_rate_limit_rules
    rules = self.class.rate_limit_rules

    if rules.empty?
      apply_default_rate_limit
      return
    end

    rules.each do |rule|
      next unless rule_applies_to_action?(rule)

      scope, discriminator = resolve_rule_scope_and_discriminator(rule)
      key = rate_limit_key(
        rule: rule[:name], tenant: rate_limit_tenant, scope: scope,
        discriminator: discriminator,
      )

      rate_limit!(
        rule: rule[:name],
        key: key,
        limit: rule[:limit],
        period: rule[:period],
        retry_after: rule[:retry_after],
        scope: scope,
      )
      break if performed?
    end
  end

  def apply_default_rate_limit
    return if Rails.env.test?

    if request.format.json?
      rate_limit_for_scope!(rule: "default_api", scope: :ip, limit: 600, period: 1.minute)
    else
      rate_limit_for_scope!(rule: "default_web", scope: :ip, limit: 300, period: 1.minute)
    end
  end

  def rate_limit_for_scope!(rule:, scope:, limit:, period:, retry_after: nil)
    scope_key = normalize_rate_limit_part(scope)
    discriminator = discriminator_for(scope)
    key = rate_limit_key(
      rule: rule, tenant: rate_limit_tenant, scope: scope_key,
      discriminator: discriminator,
    )

    rate_limit!(
      rule: rule, key: key, limit: limit, period: period, retry_after: retry_after,
      scope: scope_key,
    )
  end

  def rule_applies_to_action?(rule)
    only = rule[:only]
    except = rule[:except]

    if only.present?
      return false unless only.include?(action_name)
    end

    return false if except.present? && except.include?(action_name)

    true
  end

  def resolve_rule_scope_and_discriminator(rule)
    key_builder = rule[:key]
    return [rule[:scope], discriminator_for(rule[:scope])] unless key_builder.respond_to?(:call)

    value = instance_exec(&key_builder)

    case value
    when Array
      [value[0].to_s, value[1]]
    when Hash
      [value.fetch(:scope, rule[:scope]).to_s, value[:discriminator]]
    else
      [rule[:scope], value]
    end
  end

  def throttle_rate_limit!(rule:, scope:, retry_after:)
    retry_after_seconds = retry_after.to_i.positive? ? retry_after.to_i : DEFAULT_RETRY_AFTER
    message = I18n.t("errors.rate_limit.exceeded")

    response.headers["X-RateLimit-Layer"] = "rails"
    response.headers["X-RateLimit-Rule"] = rule.to_s
    response.headers["Retry-After"] = retry_after_seconds.to_s

    ActiveSupport::Notifications.instrument(
      "rails_rate_limit.throttled",
      rule: rule.to_s,
      tenant: rate_limit_tenant,
      scope: scope.to_s,
      path: request.path,
    )
    Rails.logger.warn(
      "[RailsRateLimit] THROTTLED rule=#{rule} tenant=#{rate_limit_tenant} " \
      "scope=#{scope} path=#{request.path}",
    )

    if request.format.json?
      render json: { error: "rate_limited", rule: rule.to_s, message: message }, status: :too_many_requests
    else
      render plain: message, status: :too_many_requests
    end
  end

  def rate_limit_store
    RailsRateLimit.store
  end

  def rate_limit_tenant
    request.host.to_s.downcase.delete_suffix(".")
  end

  def discriminator_for(scope)
    case scope.to_s
    when "ip"
      request.remote_ip
    when "user_id"
      respond_to?(:current_user, true) ? current_user&.id : nil
    when "staff_id"
      respond_to?(:current_staff, true) ? current_staff&.id : nil
    when "email"
      rate_limit_email_discriminator
    when "telephone"
      rate_limit_telephone_discriminator
    else
      nil
    end
  end

  def rate_limit_email_discriminator
    raw = params[:email] || params[:identifier] || params.dig(:user, :email)
    raw.to_s.strip.downcase.presence
  end

  def rate_limit_telephone_discriminator
    raw = params[:telephone] || params[:phone] || params.dig(:user, :telephone)
    raw.to_s.gsub(/\D/, "").presence
  end

  def normalize_rate_limit_part(value)
    candidate = value.to_s.strip
    return "anon" if candidate.blank?

    candidate.downcase
  end
end
