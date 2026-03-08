# typed: false
# frozen_string_literal: true

module Sign
  module App
    module Auth
      # Controller for handling OmniAuth callbacks (standard paths)
      #
      # Routes:
      #   GET/POST /auth/:provider/callback -> #omniauth
      #   GET/POST /auth/failure            -> #failure
      #
      # This controller handles the OmniAuth callback, validates state,
      # and delegates to SocialAuthService for user creation/linking.
      #
      # State validation is applied to ALL providers (including Apple).
      # Apple sends state in POST body, Google sends in query string.
      # Both are accessible via params[:state].
      class OmniauthCallbacksController < Sign::App::ApplicationController
        include SocialAuthConcern
        include SocialCallbackGuard
        include SessionLimitGate

        # Allow unauthenticated access for login intent
        # For link/reauth, auth is checked in prepare_social_auth_intent!
        public_strict! only: %i(omniauth failure)

        # Skip preference before_actions that may interfere with OmniAuth callback
        skip_before_action :set_region, :set_locale, :set_timezone, :set_color_theme,
                           only: %i(omniauth failure)

        # GET/POST /auth/:provider/callback
        # Handles successful OmniAuth authentication
        def omniauth
          auth = request.env["omniauth.auth"] || mock_auth_from_test_mode
          Rails.logger.debug do
            "[OmniAuth] Callback received - provider: #{auth&.provider}, uid: #{auth&.uid&.first(8)}***, " \
              "logged_in: #{logged_in?}"
          end

          unless auth
            Rails.logger.error("[OmniAuth] No auth hash found in request")
            return redirect_to new_sign_app_in_path,
                               alert: I18n.t("sign.app.social.sessions.create.failure")
          end

          ActiveRecord::Base.connected_to(role: :writing) do
            # Validate state parameter (applies to ALL providers)
            # Note: validation is skipped if session[SOCIAL_INTENT_SESSION_KEY] is blank
            Rails.logger.debug { "[OmniAuth] Validating state" }
            validate_social_auth_state!

            intent = current_social_auth_intent

            # Process the callback through service
            # IMPORTANT: Auto-link behavior is handled by overriding current_social_auth_intent
            Rails.logger.debug { "[OmniAuth] Processing callback with intent: #{intent}" }
            result = process_social_auth_callback
            user = result[:user]
            existing_account = result[:existing_account]

            Rails.logger.debug do
              "[OmniAuth] Callback processed - user_id: #{user&.id}, intent: #{intent}, " \
                "existing_account: #{existing_account}"
            end

            provider_name = SocialIdentifiable.normalize_provider(auth.provider).humanize
            intent = intent.presence || "login"

            handle_successful_auth(
              user, intent, provider_name, result[:identity],
              existing_account: existing_account,
            )
          end
        rescue SocialAuth::BaseError => e
          Rails.logger.debug { "[OmniAuth] SocialAuth error: #{e.class.name} - #{e.message}" }
          handle_social_auth_error(e)
        rescue StandardError => e
          handle_unexpected_error(e, auth)
        end

        # GET/POST /auth/failure
        # Handles OmniAuth failure (provider error, user cancellation, etc.)
        def failure
          message = params[:message] || "unknown_error"
          strategy = params[:strategy] || "unknown"

          Rails.logger.debug do
            "[OmniAuth] Failure callback - message: #{message}, strategy: #{strategy}"
          end

          clear_social_auth_intent!

          Rails.event.notify(
            "sign.social.omniauth_failure",
            message: message,
            strategy: strategy,
          )

          # Try to find a specific translation, fall back to generic
          failure_key = ["sign.app.social.sessions.failure", message].join(".")
          default_message = I18n.t("sign.app.social.sessions.create.failure")
          alert_message = I18n.t(failure_key, default: default_message)

          redirect_to new_sign_app_in_path, alert: alert_message
        end

        private

        def verified_request?
          super || (action_name == "omniauth" && verified_social_callback_request?)
        end

        def handle_unverified_request
          if action_name == "omniauth"
            rejection = request.env["social_callback_guard.rejection"] || {
              reason: "csrf_unverified",
              provider: params[:provider].to_s,
              details: {},
            }
            reject_social_callback!(**rejection)
          else
            super
          end
        end

        # rubocop:disable Metrics/MethodLength
        def handle_successful_auth(user, intent, provider_name, _identity, existing_account: nil)
          Rails.logger.debug { "[OmniAuth] handle_successful_auth - intent: #{intent}, user_id: #{user&.id}" }

          case intent
          when "link"
            Rails.logger.debug { "[OmniAuth] Link intent - redirecting to configuration" }
            default_notice = I18n.t(
              "sign.app.social.sessions.link.default",
              provider: provider_name,
              default: "%{provider} linked",
            )
            redirect_to sign_app_configuration_path,
                        notice: I18n.t(
                          "sign.app.social.sessions.link.success",
                          provider: provider_name,
                          default: default_notice,
                        )
          when "reauth"
            Rails.logger.debug { "[OmniAuth] Reauth intent - signing in with reauth" }
            login_result = sign_in_with_reauth(user)

            if login_result.is_a?(Hash) && login_result[:status] != :success
              return handle_login_failure(login_result, provider_name, user)
            end

            if login_result.is_a?(Hash) && login_result[:restricted]
              return redirect_to sign_app_in_session_path,
                                 notice: I18n.t("sign.app.in.session.restricted_notice")
            end

            redirect_to social_auth_success_redirect_path,
                        notice: I18n.t("sign.app.social.sessions.reauth.success", provider: provider_name)
          else
            Rails.logger.debug { "[OmniAuth] Login intent - signing in user" }
            login_result = sign_in(user)

            # Check if login failed
            if login_result.is_a?(Hash) && login_result[:status] != :success
              Rails.logger.warn do
                "[OmniAuth] Login failed - status: #{login_result[:status]}, user_id: #{user.id}"
              end
              return handle_login_failure(login_result, provider_name, user)
            end

            # Check if session is restricted (session limit exceeded)
            if login_result.is_a?(Hash) && login_result[:restricted]
              return redirect_to sign_app_in_session_path,
                                 notice: I18n.t("sign.app.in.session.restricted_notice")
            end

            Rails.logger.debug { "[OmniAuth] Login successful - redirecting" }
            if existing_account
              issue_checkpoint!
              redirect_to sign_app_in_checkpoint_path(ri: params[:ri]),
                          notice: I18n.t(
                            "sign.app.social.sessions.create.already_registered",
                            provider: provider_name,
                          )
            else
              issue_checkpoint!
              redirect_to sign_app_in_checkpoint_path(ri: params[:ri]),
                          notice: I18n.t("sign.app.social.sessions.create.success", provider: provider_name)
            end
          end
        end

        # rubocop:enable Metrics/MethodLength

        def handle_unexpected_error(error, auth)
          Rails.event.notify(
            "sign.social.unexpected_error",
            error_class: error.class.name,
            error_message: error.message,
            provider: auth&.provider,
          )
          backtrace_lines = error.backtrace&.first(10) || []
          Rails.logger.error(
            (["[OmniAuth] Unexpected error: #{error.class} - #{error.message}"] + backtrace_lines).join("\n"),
          )

          clear_social_auth_intent!
          redirect_to new_sign_app_in_path,
                      alert: I18n.t("sign.app.social.sessions.create.failure")
        end

        def sign_in(user)
          result = complete_sign_in_or_start_mfa!(
            user, rt: nil, ri: params[:ri], auth_method: "social",
          )
          Rails.logger.debug { "[OmniAuth] sign_in result: #{result.inspect}" }
          result
        end

        def sign_in_with_reauth(user)
          # Reauth flow - last_reauth_at is already updated by SocialAuthService
          result = complete_sign_in_or_start_mfa!(
            user, rt: nil, ri: params[:ri], auth_method: "social",
          )
          Rails.logger.debug { "[OmniAuth] sign_in (reauth) result: #{result.inspect}" }
          result
        end

        # Handle login failures (session limit, MFA required, etc.)
        def handle_login_failure(login_result, _provider_name, _user = nil)
          status = login_result[:status]

          case status
          when :session_limit_hard_reject
            render_session_limit_hard_reject(
              message: login_result[:message],
              http_status: login_result[:http_status],
            )
          when :session_limit_exceeded
            Rails.logger.debug { "[OmniAuth] Session limit exceeded for user" }
            redirect_to new_sign_app_in_path,
                        alert: I18n.t("sign.app.social.sessions.create.session_limit")
          when :mfa_required
            Rails.logger.debug { "[OmniAuth] MFA required for user" }
            safe_redirect_to(
              login_result[:redirect_path],
              fallback: new_sign_app_in_path,
              notice: I18n.t("sign.app.in.mfa.required"),
            )
          else
            Rails.logger.warn { "[OmniAuth] Unknown login failure status: #{status}" }
            redirect_to new_sign_app_in_path,
                        alert: I18n.t("sign.app.social.sessions.create.failure")
          end
        end

        # For test mode, get mock auth hash from OmniAuth config
        def mock_auth_from_test_mode
          return unless Rails.env.test?

          provider = params[:provider]
          return unless provider

          OmniAuth.config.mock_auth[provider.to_sym] || OmniAuth.config.mock_auth[provider.to_s]
        end

        def social_auth_failure_redirect_path
          new_sign_app_in_path
        end

        def social_auth_success_redirect_path
          sign_app_configuration_path
        end

        def validate_social_auth_state!
          intent = current_social_auth_intent
          if intent == "link" && auto_link_allowed? && (logged_in? || test_user_from_header.present?)
            session[SOCIAL_FLOW_ID_SESSION_KEY] ||= SecureRandom.hex(16)
            session[SOCIAL_USER_ID_SESSION_KEY] ||= (current_resource || test_user_from_header)&.id
            session[SOCIAL_STARTED_AT_SESSION_KEY] ||= Time.current.to_i
            session[SOCIAL_PROVIDER_SESSION_KEY] ||= params[:provider]
          end

          super
        end

        # Override to support auto-link when user is already logged in
        # IMPORTANT: This ensures UserSocialApple/UserSocialGoogle is created and linked to current_user
        # Without this, callback defaults to "login" intent and creates a NEW user instead
        def current_social_auth_intent
          explicit_intent = session[SOCIAL_INTENT_SESSION_KEY]

          # If explicit intent is set (via /social/start), use it
          return explicit_intent if explicit_intent.present?

          # Auto-link: if user is logged in and no explicit intent, default to "link"
          # This handles the case where user clicks Apple Sign In while already logged in
          test_user = test_user_from_header
          if logged_in? || test_user.present?
            session[SOCIAL_INTENT_SESSION_KEY] = "link"
            if auto_link_allowed?
              session[SOCIAL_USER_ID_SESSION_KEY] = (current_resource || test_user)&.id
              session[SOCIAL_STARTED_AT_SESSION_KEY] ||= Time.current.to_i
              session[SOCIAL_FLOW_ID_SESSION_KEY] ||= SecureRandom.hex(16)
              session[SOCIAL_PROVIDER_SESSION_KEY] ||= params[:provider]
            end
            return "link"
          end

          # Default: login flow for non-logged-in users
          "login"
        end

        def social_auth_user
          super || test_user_from_header
        end

        def test_user_from_header
          return nil unless Rails.env.test?

          test_id = request.headers["X-TEST-CURRENT-USER"]
          return nil if test_id.blank?

          User.find_by(id: test_id)
        end

        def auto_link_allowed?
          request.get? || request.head?
        end
      end
    end
  end
end
