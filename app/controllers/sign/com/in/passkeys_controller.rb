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

        before_action :reject_logged_in_session

        def new
        end

        private

        def identity_email_model
          CustomerEmail
        end

        def identity_telephone_model
          CustomerTelephone
        end

        def identity_from_email_record(record)
          record&.customer
        end

        def identity_from_telephone_record(record)
          record&.customer
        end

        def find_active_passkey_actor(identifier)
          customer = find_user_by_identifier(identifier)
          customer if customer&.active?
        end

        def passkey_identifier_required_error_key
          "errors.webauthn.pii_required"
        end

        def before_passkey_options_request!
          verify_turnstile_stealth!
        end

        def allow_passkey_options_for_actor?(customer)
          if session_limit_hard_reject_for?(customer)
            render_session_limit_hard_reject
            return false
          end

          true
        end

        def active_passkeys_for_actor(customer)
          customer.customer_passkeys.where(status_id: CustomerPasskeyStatus::ACTIVE)
        end

        def passkey_challenge_actor_id_key
          "customer_id"
        end

        def passkey_sign_in_model
          CustomerPasskey
        end

        def passkey_belongs_to_challenge_actor?(passkey, actor_id)
          passkey.customer_id == actor_id
        end

        def passkey_owner_mismatch_log_message
          "WebAuthn: Credential not found or customer mismatch"
        end

        def allow_passkey_sign_in?(passkey)
          return true if passkey.customer.has_verified_pii?

          Rails.event.notify(
            "authentication.passkey.failed",
            reason: "verified_pii_missing",
            customer_id: passkey.customer_id,
            ip_address: request.remote_ip,
          )
          render_error("errors.webauthn.credential_not_found", :unauthorized)
          false
        end

        def perform_passkey_sign_in(passkey)
          rd = retrieve_redirect_parameter_for_bulletin
          complete_sign_in_or_start_mfa!(
            passkey.customer, rt: rd, ri: params[:ri], auth_method: "passkey",
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
