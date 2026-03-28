# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module In
      class PasskeysController < ApplicationController
        include Sign::Webauthn
        include Sign::PasskeyAuthentication
        include Sign::PasskeyAuthenticationHelpers
        include Sign::PasskeyOptionsFlow
        include Sign::PasskeyVerificationFlow
        include Sign::PasskeySignInFlow
        include Sign::PasskeyLoginResultFlow
        include EmailValidation
        include IdentifierDetection
        include MinimumResponseBudget
        include SessionLimitGate
        include CloudflareTurnstile
        include Sign::Com::ControllerBehavior

        before_action :reject_logged_in_session

        def new
        end

        private

        def find_active_passkey_actor(identifier)
          user = find_user_by_identifier(identifier)
          user if user&.active?
        end

        def passkey_identifier_required_error_key
          "errors.webauthn.pii_required"
        end

        def before_passkey_options_request!
          verify_turnstile_stealth!
        end

        def allow_passkey_options_for_actor?(user)
          if session_limit_hard_reject_for?(user)
            render_session_limit_hard_reject
            return false
          end

          true
        end

        def active_passkeys_for_actor(user)
          user.user_passkeys.where(status_id: UserPasskeyStatus::ACTIVE)
        end

        def passkey_challenge_actor_id_key
          "user_id"
        end

        def passkey_sign_in_model
          UserPasskey
        end

        def passkey_belongs_to_challenge_actor?(passkey, actor_id)
          passkey.user_id == actor_id
        end

        def passkey_owner_mismatch_log_message
          "WebAuthn: Credential not found or user mismatch"
        end

        def allow_passkey_sign_in?(passkey)
          return true if passkey.user.has_verified_pii?

          Rails.event.notify(
            "authentication.passkey.failed",
            reason: "verified_pii_missing",
            user_id: passkey.user_id,
            ip_address: request.remote_ip,
          )
          render_error("errors.webauthn.credential_not_found", :unauthorized)
          false
        end

        def perform_passkey_sign_in(passkey)
          rd = retrieve_redirect_parameter_for_bulletin
          complete_sign_in_or_start_mfa!(
            passkey.user, rt: rd, ri: params[:ri], auth_method: "passkey",
          )
        end

        def handle_domain_specific_login_status(result)
          case result[:status]
          when :mfa_required
            render json: { status: "mfa_required", redirect_url: result[:redirect_path] }, status: :ok
            true
          when :session_limit_hard_reject
            render_session_limit_hard_reject(message: result[:message], http_status: result[:http_status])
            true
          else
            false
          end
        end

        def passkey_success_restricted?(result)
          result[:restricted]
        end

        def render_passkey_restricted_success(_result)
          render json: {
            status: "session_restricted",
            redirect_url: sign_com_in_session_path,
            message: I18n.t("sign.app.in.session.restricted_notice"),
          }, status: :ok
        end

        def passkey_bulletin_redirect_url
          sign_com_in_bulletin_path(
            rd: retrieve_redirect_parameter_for_bulletin,
            ri: params[:ri],
          )
        end

        def passkey_default_redirect_url
          sign_com_configuration_path(ri: params[:ri])
        end

        def minimum_response_budget_enabled?
          action_name == "options"
        end
      end
    end
  end
end
