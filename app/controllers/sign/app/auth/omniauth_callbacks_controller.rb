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

        # Allow unauthenticated access for login intent
        # For link/reauth, auth is checked in prepare_social_auth_intent!
        public_strict! only: %i(omniauth failure)

        # CSRF protection is handled by state parameter, not token
        skip_forgery_protection only: %i(omniauth failure)

        # Skip preference before_actions that may interfere with OmniAuth callback
        skip_before_action :set_region, :set_locale, :set_timezone, :set_color_theme, only: %i(omniauth failure)

        # GET/POST /auth/:provider/callback
        # Handles successful OmniAuth authentication
        def omniauth
          auth = request.env["omniauth.auth"] || mock_auth_from_test_mode

          unless auth
            Rails.logger.error("[OmniAuth] No auth hash found in request")
            return redirect_to new_sign_app_in_path,
                               alert: I18n.t("sign.app.social.sessions.create.failure")
          end

          ActiveRecord::Base.connected_to(role: :writing) do
            # Validate state parameter (applies to ALL providers)
            validate_social_auth_state!

            # Process the callback through service
            result = process_social_auth_callback
            user = result[:user]
            intent = current_social_auth_intent
            existing_account = result[:existing_account]

            provider_name = SocialIdentifiable.normalize_provider(auth.provider).humanize
            intent = intent.presence || "login"

            handle_successful_auth(user, intent, provider_name, result[:identity], existing_account: existing_account)
          end
        rescue SocialAuth::BaseError => e
          handle_social_auth_error(e)
        rescue StandardError => e
          handle_unexpected_error(e, auth)
        end

        # GET/POST /auth/failure
        # Handles OmniAuth failure (provider error, user cancellation, etc.)
        def failure
          clear_social_auth_intent!

          message = params[:message] || "unknown_error"
          strategy = params[:strategy] || "unknown"

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

        def handle_successful_auth(user, intent, provider_name, _identity, existing_account: nil)
          case intent
          when "link"
            redirect_to sign_app_configuration_path,
                        notice: I18n.t("sign.app.social.sessions.link.success", provider: provider_name)
          when "reauth"
            sign_in_with_reauth(user)
            redirect_to social_auth_success_redirect_path,
                        notice: I18n.t("sign.app.social.sessions.reauth.success", provider: provider_name)
          else
            sign_in(user)
            if existing_account
              redirect_to social_auth_success_redirect_path,
                          notice: I18n.t("sign.app.social.sessions.create.already_registered", provider: provider_name)
            else
              redirect_to social_auth_success_redirect_path,
                          notice: I18n.t("sign.app.social.sessions.create.success", provider: provider_name)
            end
          end
        end

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
          log_in(user)
        end

        def sign_in_with_reauth(user)
          # Reauth flow - last_reauth_at is already updated by SocialAuthService
          log_in(user)
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
      end
    end
  end
end
