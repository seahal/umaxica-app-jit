# frozen_string_literal: true

# app/controllers/concerns/auth/policy.rb

module Auth
  module Policy
    extend ActiveSupport::Concern

    class MissingPolicyError < StandardError; end

    class InvalidPolicyError < StandardError; end

    class SkipNotAllowedError < StandardError; end

    VALID_POLICIES = %i(
      public_strict
      auth_required
      guest_only
    ).freeze

    ACCESS_POLICY_RULES = Concurrent::Map.new

    included do
      # Important: prepend first so this runs before other before_action hooks.
      prepend_before_action :enforce_access_policy!
    end

    class_methods do
      # Declare policy for controller or specific actions (only/except).
      def access_policy_rules
        ACCESS_POLICY_RULES.fetch_or_store(self) do
          parent_rules =
            if superclass.respond_to?(:access_policy_rules)
              superclass.access_policy_rules
            else
              []
            end
          parent_rules.dup
        end
      end

      def access_policy(policy, only: nil, except: nil, **options)
        policy = policy.to_sym
        raise InvalidPolicyError, "Invalid policy: #{policy.inspect}" unless VALID_POLICIES.include?(policy)

        rule = {
          policy: policy,
          only: Array(only).map(&:to_s).presence,
          except: Array(except).map(&:to_s).presence,
          options: options,
        }

        ACCESS_POLICY_RULES[self] = access_policy_rules + [rule]
      end

      # Readable shortcuts.
      def public_strict!(**) = access_policy(:public_strict, **)

      def auth_required!(**) = access_policy(:auth_required, **)

      def guest_only!(**) = access_policy(:guest_only, **)

      # --- Skip guardrails ---
      # Disallow removing enforce_access_policy! via skip_before_action.
      def skip_before_action(*filters, **options)
        filters = filters.flatten
        filters.map!(&:to_sym)
        if filters.include?(:enforce_access_policy!)
          raise SkipNotAllowedError, "skip_before_action :enforce_access_policy! is prohibited (#{name})"
        end

        super
      end

      # Some code uses skip_action_callback, so lock this down too.
      def skip_action_callback(*args, **kwargs)
        # skip_action_callback(:process_action, :before, :enforce_access_policy!)
        if args.map(&:to_sym).include?(:enforce_access_policy!)
          raise SkipNotAllowedError, "skip_action_callback :enforce_access_policy! is prohibited (#{name})"
        end

        super
      end
    end

    private

    def enforce_access_policy!
      rule = resolve_access_policy_for(action_name)

      if rule.nil?
        Rails.logger.warn "AUTH_POLICY: Missing for #{self.class.name}##{action_name}"
        raise MissingPolicyError,
              "Missing access_policy for #{self.class.name}##{action_name}. " \
              "Declare one of: #{VALID_POLICIES.join(", ")}"
      end

      policy = rule[:policy]
      options = rule[:options] || {}

      Rails.logger.warn(
        "AUTH_POLICY: Resolved #{policy} for #{self.class.name}##{action_name} " \
        "(Rules: #{self.class.access_policy_rules.size})",
      )

      case policy
      when :public_strict
        enforce_public_strict!(options)
      when :auth_required
        enforce_auth_required!(options)
      when :guest_only
        enforce_guest_only!(options)
      else
        raise InvalidPolicyError, "Unexpected policy: #{policy.inspect}"
      end
    end

    def resolve_access_policy_for(action)
      action = action.to_s

      # Last rule wins so controller-wide policies can be overridden per action.
      rules = self.class.access_policy_rules
      return nil if rules.blank?

      rules.reverse_each do |rule|
        next if rule[:only].present? && rule[:only].exclude?(action)
        next if rule[:except].present? && rule[:except].include?(action)

        return rule
      end

      nil
    end

    # --- Behavior implementation (align with your auth stack) ---

    def enforce_public_strict!(_options = {})
      # If you avoid touching current_user/current_resource here,
      # the safest default is to do nothing.
      true
    end

    def enforce_auth_required!(options = {})
      # Example: use Auth::Base logged_in? / current_resource.
      return true if respond_to?(:logged_in?) && logged_in?

      # Branch HTML vs API (or delegate to your responder).
      if request.format.json? || options[:request_format] == :json
        status = options[:status] || :unauthorized
        render json: { error: (options[:message] || "unauthorized") }, status: status
      else
        path =
          if respond_to?(:sign_in_url_with_return, true)
            rt = Base64.urlsafe_encode64(request.original_url)
            sign_in_url_with_return(rt)
          elsif main_app.respond_to?(:sign_in_path)
            main_app.sign_in_path
          else
            "/sign/in"
          end
        message = options[:message] || I18n.t("errors.messages.login_required")
        redirect_to(path, allow_other_host: true, alert: message)
      end
    end

    def enforce_guest_only!(options = {})
      # Guest-only policy: block logged-in users.
      return true unless respond_to?(:logged_in?) && logged_in?

      if request.format.json? || options[:request_format] == :json
        status = options[:status] || :forbidden
        render json: { error: (options[:message] || "already_authenticated") }, status: status
      else
        if options[:status] == :unauthorized
          return render plain: (options[:message] || "権限がありません"), status: :unauthorized
        end
        if options[:status] == :bad_request
          return render plain: (options[:message] || "リクエストが不正です"), status: :bad_request
        end

        path =
          if respond_to?(:after_login_path, true)
            after_login_path
          elsif main_app.respond_to?(:after_login_path)
            main_app.after_login_path
          else
            "/"
          end
        message = options[:message] || I18n.t("errors.messages.already_authenticated")
        redirect_to(path, allow_other_host: true, alert: message)
      end
    end
  end
end
