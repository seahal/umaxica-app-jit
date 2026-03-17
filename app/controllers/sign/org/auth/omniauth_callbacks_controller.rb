# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module Auth
      # Controller for handling Google OAuth callbacks for staff sign-in.
      #
      # Routes:
      #   GET /auth/:provider/callback -> #omniauth
      #   GET /auth/failure            -> #failure
      #
      # Staff sign-in only (no sign-up):
      # - Extracts email from Google auth hash
      # - Looks up Staff via StaffEmail by that email
      # - Signs in the staff if found and active
      class OmniauthCallbacksController < Sign::Org::ApplicationController
        include SocialAuthConcern
        include SocialCallbackGuard
        include SessionLimitGate

        public_strict! only: %i(omniauth failure)

        skip_before_action :set_region, :set_locale, :set_timezone, :set_color_theme,
                           only: %i(omniauth failure)

        # GET/POST /auth/:provider/callback
        def omniauth
          auth = request.env["omniauth.auth"] || mock_auth_from_test_mode
          Rails.event.debug(
            "sign.social.org.omniauth.callback_received",
            provider: auth&.provider,
          )

          unless auth
            Rails.event.error("sign.social.org.omniauth.missing_auth_hash")
            return redirect_to new_sign_org_in_path,
                               alert: I18n.t("sign.org.social.sessions.create.failure")
          end

          validate_social_auth_state!

          email = extract_email_from_auth(auth)
          staff = find_active_staff_by_google_email(email)

          unless staff
            Rails.event.notify(
              "sign.social.org.omniauth.staff_not_found",
              provider: auth.provider,
              email_present: email.present?,
            )
            clear_social_auth_intent!
            return redirect_to new_sign_org_in_path,
                               alert: I18n.t("sign.org.social.sessions.create.not_found")
          end

          Rails.event.debug(
            "sign.social.org.omniauth.staff_found",
            staff_id: staff.id,
          )

          clear_social_auth_intent!
          login_result = log_in(staff, record_login_audit: true)

          provider_name = SocialIdentifiable.normalize_provider(auth.provider).humanize
          handle_login_result(login_result, provider_name)
        rescue SocialAuth::BaseError => e
          handle_social_auth_error(e)
        rescue StandardError => e
          handle_unexpected_error(e, auth)
        end

        # GET /auth/failure
        def failure
          message = params[:message] || "unknown_error"
          clear_social_auth_intent!
          Rails.event.record("sign.social.org.omniauth_failure", message: message)
          redirect_to new_sign_org_in_path,
                      alert: I18n.t("sign.org.social.sessions.create.failure")
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

        def extract_email_from_auth(auth)
          email = auth.dig("info", "email") || auth.dig(:info, :email)
          email&.strip&.downcase
        end

        def find_active_staff_by_google_email(email)
          return nil if email.blank?

          staff_email = StaffEmail.find_by(address: email)
          staff = staff_email&.staff
          staff if staff&.status_id == StaffStatus::ACTIVE
        end

        # rubocop:disable Metrics/MethodLength
        def handle_login_result(result, provider_name)
          if result.is_a?(Hash) && result[:status] != :success
            case result[:status]
            when :session_limit_hard_reject
              render_session_limit_hard_reject(
                message: result[:message],
                http_status: result[:http_status],
              )
            when :session_limit_exceeded
              redirect_to new_sign_org_in_path,
                          alert: I18n.t("sign.org.social.sessions.create.session_limit")
            else
              redirect_to new_sign_org_in_path,
                          alert: I18n.t("sign.org.social.sessions.create.failure")
            end
          elsif result.is_a?(Hash) && result[:restricted]
            redirect_to sign_org_in_session_path,
                        notice: I18n.t(
                          "sign.org.in.session.restricted_notice",
                          default: "セッション数が上限に達しています。既存セッションを管理してください。",
                        )
          else
            issue_checkpoint!
            redirect_to sign_org_in_checkpoint_path(ri: params[:ri]),
                        notice: I18n.t("sign.org.social.sessions.create.success", provider: provider_name)
          end
        end

        # rubocop:enable Metrics/MethodLength

        def handle_unexpected_error(error, auth)
          Rails.event.error(
            "sign.social.org.omniauth.unexpected_error",
            error_class: error.class.name,
            error_message: error.message,
            provider: auth&.provider,
            exception: error,
          )
          clear_social_auth_intent!
          redirect_to new_sign_org_in_path,
                      alert: I18n.t("sign.org.social.sessions.create.failure")
        end

        def mock_auth_from_test_mode
          return unless Rails.env.test?

          provider = params[:provider]
          return unless provider

          OmniAuth.config.mock_auth[provider.to_sym] || OmniAuth.config.mock_auth[provider.to_s]
        end

        def social_auth_failure_redirect_path
          new_sign_org_in_path
        end

        def social_auth_success_redirect_path
          sign_org_configuration_path
        end

        # Override to use org path instead of app path
        def reject_social_callback!(reason:, provider:, details: {})
          clear_social_state!
          Rails.logger.warn(
            "[SocialCallbackGuard] org phase=callback provider=#{provider.inspect} " \
            "reason=#{reason} details=#{details.inspect}",
          )
          redirect_to new_sign_org_in_path,
                      alert: I18n.t("sign.org.social.sessions.create.failure"),
                      status: :forbidden
        end
      end
    end
  end
end
