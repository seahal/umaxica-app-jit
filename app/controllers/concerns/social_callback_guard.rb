# frozen_string_literal: true

require "uri"

module SocialCallbackGuard
  extend ActiveSupport::Concern

  STATE_TTL = 5.minutes
  SOCIAL_STATE_SESSION_KEY = :social_auth_state
  SOCIAL_STATE_STARTED_AT_SESSION_KEY = :social_auth_state_started_at
  SOCIAL_STATE_USED_AT_SESSION_KEY = :social_auth_state_used_at
  SOCIAL_STATE_PROVIDER_SESSION_KEY = :social_auth_state_provider

  REQUEST_ALLOWED_METHODS_BY_PROVIDER = {
    "apple" => %w(POST GET).freeze,
    "google_oauth2" => %w(POST GET).freeze,
  }.freeze

  CALLBACK_ALLOWED_METHODS_BY_PROVIDER = {
    "apple" => %w(POST).freeze,
    "google_oauth2" => %w(GET).freeze,
  }.freeze

  REQUEST_PHASE_PATH = %r{\A/auth/(?<provider>google_oauth2|apple)\z}.freeze

  included do
    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :verify_social_callback_request!, only: :omniauth
    # rubocop:enable Rails/LexicallyScopedActionFilter
  end

  module_function

  def verify_request_phase!(env)
    request = Rack::Request.new(env)
    match = REQUEST_PHASE_PATH.match(request.path_info.to_s)
    return unless match

    provider = match[:provider]
    method = request.request_method.to_s.upcase

    unless allowed_request_method?(provider, method)
      return reject_request_phase!(
        phase: "request",
        reason: "bad_method",
        provider: provider,
        details: { method: method },
      )
    end

    source, normalized = normalized_request_source(request)
    if normalized.nil?
      return reject_request_phase!(
        phase: "request",
        reason: "origin_mismatch_request_phase",
        provider: provider,
        details: { source: source },
      )
    end

    unless allowed_request_origins.include?(normalized)
      return reject_request_phase!(
        phase: "request",
        reason: "origin_mismatch_request_phase",
        provider: provider,
        details: { source: source, origin: normalized },
      )
    end

    ensure_state_query_param!(env, request, provider)
    nil
  end

  def capture_request_state!(env)
    request = Rack::Request.new(env)
    match = REQUEST_PHASE_PATH.match(request.path_info.to_s)
    return unless match

    provider = match[:provider]
    state = request.session["omniauth.state"].to_s.presence || request.params["state"].to_s.presence
    return if state.blank?

    request.session[SOCIAL_STATE_SESSION_KEY] = state
    request.session[SOCIAL_STATE_STARTED_AT_SESSION_KEY] = Time.current.to_i
    request.session[SOCIAL_STATE_USED_AT_SESSION_KEY] = nil
    request.session[SOCIAL_STATE_PROVIDER_SESSION_KEY] = provider
  end

  def allowed_request_method?(provider, method)
    allowed = REQUEST_ALLOWED_METHODS_BY_PROVIDER[provider]
    allowed.present? && allowed.include?(method)
  end

  def allowed_callback_method?(provider, method)
    allowed = CALLBACK_ALLOWED_METHODS_BY_PROVIDER[provider]
    allowed.present? && allowed.include?(method)
  end

  def allowed_hosts
    @allowed_hosts ||=
      begin
        hosts = [ENV["SIGN_SERVICE_URL"], ENV["SIGN_STAFF_URL"]].compact.filter_map { |v| normalize_host_port(v) }
        hosts.uniq
      end
  end

  def allowed_request_origins
    @allowed_request_origins ||=
      begin
        origins = []
        schemes = %w(https)
        schemes << "http" if Rails.env.local?

        allowed_hosts.each do |host|
          schemes.each do |scheme|
            origins << "#{scheme}://#{host}"
          end
        end
        origins.uniq
      end
  end

  def normalize_host_port(value)
    raw = value.to_s.strip
    return nil if raw.blank?

    candidate = raw.include?("://") ? raw : "https://#{raw}"
    uri = URI.parse(candidate)
    return nil if uri.host.blank?

    host = uri.host.downcase
    default = (uri.scheme == "https") ? 443 : 80
    if uri.port && uri.port != default
      "#{host}:#{uri.port}"
    else
      host
    end
  rescue URI::InvalidURIError
    nil
  end

  def normalize_origin(value)
    uri = URI.parse(value.to_s)
    return nil unless uri.scheme && uri.host
    return nil unless %w(http https).include?(uri.scheme)

    origin = "#{uri.scheme.downcase}://#{uri.host.downcase}"
    default_port = (uri.scheme == "https") ? 443 : 80
    origin += ":#{uri.port}" if uri.port && uri.port != default_port
    origin
  rescue URI::InvalidURIError
    nil
  end

  def sanitize_source_header(value)
    normalize_origin(value)
  end

  private

  def verify_social_callback_request!
    provider = params[:provider].to_s
    method = request.request_method.to_s.upcase

    unless SocialCallbackGuard.allowed_callback_method?(provider, method)
      return reject_social_callback!(
        reason: "bad_method",
        provider: provider,
        details: { method: method },
      )
    end

    host = SocialCallbackGuard.normalize_host_port(request.host_with_port)
    unless SocialCallbackGuard.allowed_hosts.include?(host)
      return reject_social_callback!(
        reason: "host_mismatch",
        provider: provider,
        details: { host: host },
      )
    end

    log_callback_source(provider)
    valid_state, state_reason = valid_callback_state?(provider)
    return if valid_state

    reject_social_callback!(
      reason: "bad_state",
      provider: provider,
      details: { state_reason: state_reason },
    )
  end

  def valid_callback_state?(provider)
    callback_state = params[:state].to_s.presence
    expected_state = session[SOCIAL_STATE_SESSION_KEY].to_s.presence
    expected_state ||= request.env.dig("omniauth.params", "state").to_s.presence
    started_at = session[SOCIAL_STATE_STARTED_AT_SESSION_KEY].to_i
    used_at = session[SOCIAL_STATE_USED_AT_SESSION_KEY]
    stored_provider = session[SOCIAL_STATE_PROVIDER_SESSION_KEY].to_s.presence

    if callback_state.blank? || expected_state.blank?
      if allow_test_mode_state_bypass?
        synthetic_state = callback_state || expected_state || SecureRandom.hex(16)
        session[SOCIAL_STATE_SESSION_KEY] = synthetic_state
        session[SOCIAL_STATE_PROVIDER_SESSION_KEY] ||= provider
        session[SOCIAL_STATE_STARTED_AT_SESSION_KEY] = Time.current.to_i
        session[SOCIAL_STATE_USED_AT_SESSION_KEY] = nil
        callback_state ||= synthetic_state
        expected_state ||= synthetic_state
      end
    end

    return [clear_social_state! && false, "missing_callback_state"] if callback_state.blank?
    return [clear_social_state! && false, "missing_expected_state"] if expected_state.blank?

    return [clear_social_state! && false,
            "provider_mismatch",] if stored_provider.present? && stored_provider != provider
    return [clear_social_state! && false, "state_reused"] if used_at.present?
    return [clear_social_state! && false, "state_mismatch"] unless ActiveSupport::SecurityUtils.secure_compare(
      callback_state, expected_state,
    )

    return [clear_social_state! && false,
            "state_expired",] if started_at.positive? && Time.current > Time.zone.at(started_at) + STATE_TTL

    session[SOCIAL_STATE_SESSION_KEY] = expected_state
    session[SOCIAL_STATE_PROVIDER_SESSION_KEY] ||= provider
    session[SOCIAL_STATE_STARTED_AT_SESSION_KEY] =
      Time.current.to_i if session[SOCIAL_STATE_STARTED_AT_SESSION_KEY].blank?
    session[SOCIAL_STATE_USED_AT_SESSION_KEY] = Time.current.to_i
    [true, nil]
  rescue StandardError
    clear_social_state!
    [false, "state_parse_error"]
  end

  def allow_test_mode_state_bypass?
    return false unless Rails.env.test?
    return false if request.headers["X-STRICT-SOCIAL-STATE"] == "1"

    request.env["omniauth.auth"].present?
  end

  def clear_social_state!
    session.delete(SOCIAL_STATE_SESSION_KEY)
    session.delete(SOCIAL_STATE_STARTED_AT_SESSION_KEY)
    session.delete(SOCIAL_STATE_USED_AT_SESSION_KEY)
    session.delete(SOCIAL_STATE_PROVIDER_SESSION_KEY)
  end

  def log_callback_source(provider)
    source = {}
    source[:origin] =
      SocialCallbackGuard.sanitize_source_header(request.headers["Origin"]) if request.headers["Origin"].present?
    source[:referer] =
      SocialCallbackGuard.sanitize_source_header(request.headers["Referer"]) if request.headers["Referer"].present?

    Rails.logger.info(
      "[SocialCallbackGuard] phase=callback provider=#{provider.inspect} " \
      "reason=source_observed details=#{source.inspect}"
    )
  end

  def reject_social_callback!(reason:, provider:, details: {})
    clear_social_state!

    Rails.logger.warn(
      "[SocialCallbackGuard] phase=callback provider=#{provider.inspect} reason=#{reason} details=#{details.inspect}",
    )

    redirect_to new_sign_app_in_path,
                alert: I18n.t("sign.app.social.sessions.create.failure"),
                status: :forbidden
  end

  def self.normalized_request_source(request)
    origin = request.get_header("HTTP_ORIGIN").presence
    if origin.present?
      normalized = normalize_origin(origin)
      return [:origin, normalized] if normalized

      return [:origin_parse_error, nil]
    end

    referer = request.referer.to_s.presence
    if referer.present?
      normalized = normalize_origin(referer)
      return [:referer, normalized] if normalized

      return [:referer_parse_error, nil]
    end

    [:missing_source, nil]
  end

  def self.ensure_state_query_param!(env, request, provider)
    query = request.GET.dup
    if query["state"].present?
      request.session[SOCIAL_STATE_SESSION_KEY] = query["state"].to_s
      request.session[SOCIAL_STATE_STARTED_AT_SESSION_KEY] = Time.current.to_i
      request.session[SOCIAL_STATE_USED_AT_SESSION_KEY] = nil
      request.session[SOCIAL_STATE_PROVIDER_SESSION_KEY] = provider
      return
    end

    generated_state = SecureRandom.hex(24)
    query["state"] = generated_state

    env["QUERY_STRING"] = Rack::Utils.build_query(query)
    env.delete("rack.request.query_hash")
    env.delete("rack.request.query_string")

    request.session[SOCIAL_STATE_SESSION_KEY] = generated_state
    request.session[SOCIAL_STATE_STARTED_AT_SESSION_KEY] = Time.current.to_i
    request.session[SOCIAL_STATE_USED_AT_SESSION_KEY] = nil
    request.session[SOCIAL_STATE_PROVIDER_SESSION_KEY] = provider
  end

  def self.reject_request_phase!(phase:, reason:, provider:, details: {})
    Rails.logger.warn(
      "[SocialCallbackGuard] phase=#{phase} provider=#{provider.inspect} reason=#{reason} details=#{details.inspect}",
    )

    body = I18n.t("sign.app.social.sessions.create.failure")
    [403, { "Content-Type" => "text/plain; charset=utf-8" }, [body]]
  end
end
