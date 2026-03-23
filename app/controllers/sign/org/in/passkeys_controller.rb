# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module In
      # PasskeysController handles Passkey-based staff authentication.
      #
      # Flow:
      # 1. Staff visits /in/passkeys/new and enters their staff public_id
      # 2. POST /in/passkeys/options with identifier to get WebAuthn challenge
      # 3. Browser performs navigator.credentials.get()
      # 4. POST /in/passkeys/verification with credential + challenge_id
      # 5. Server verifies and establishes session via Auth::Base#log_in
      #
      # Note: Discoverable credentials (passwordless without identifier) are
      # planned for a future phase. Currently, identifier is required to look up
      # the staff's registered passkeys.
      class PasskeysController < ApplicationController
        include Sign::Webauthn
        include Sign::PasskeyAuthentication
        include Sign::PasskeyAuthenticationHelpers
        include Sign::PasskeyOptionsFlow
        include Sign::PasskeyVerificationFlow
        include Sign::PasskeySignInFlow
        include Sign::PasskeyLoginResultFlow
        include MinimumResponseBudget
        include SessionLimitGate
        include CloudflareTurnstile

        before_action :reject_logged_in_session

        guest_only!

        # GET /in/passkeys/new
        # Render login page with identifier input and passkey button
        def new
        end

        private

        def before_passkey_options_request!
          verify_turnstile_stealth!
        end

        def normalized_passkey_identifier
          Staff.normalize_public_id(params[:identifier])
        end

        def valid_passkey_identifier?(identifier)
          Staff::PUBLIC_ID_FORMAT.match?(identifier)
        end

        def passkey_identifier_invalid_error_key
          "errors.webauthn.identifier_invalid"
        end

        def find_active_passkey_actor(identifier)
          normalized_identifier = Staff.normalize_public_id(identifier)
          return if normalized_identifier.blank?

          staff = Staff.find_by(public_id: normalized_identifier)
          staff if staff&.login_allowed?
        end

        def active_passkeys_for_actor(staff)
          staff.staff_passkeys.where(status_id: StaffPasskeyStatus::ACTIVE)
        end

        def passkey_challenge_actor_id_key
          "staff_id"
        end

        def passkey_sign_in_model
          StaffPasskey
        end

        def passkey_belongs_to_challenge_actor?(passkey, actor_id)
          passkey.staff_id == actor_id
        end

        def passkey_owner_mismatch_log_message
          "WebAuthn: Credential not found or staff mismatch"
        end

        def perform_passkey_sign_in(passkey)
          complete_sign_in_or_start_mfa!(
            passkey.staff, rt: retrieve_redirect_parameter_for_bulletin, ri: params[:ri], auth_method: "passkey",
          )
        end

        def handle_domain_specific_login_status(result)
          case result[:status]
          when :totp_required
            render json: { status: "totp_required", redirect_url: new_sign_org_in_totp_path }, status: :ok
            true
          when :session_limit_hard_reject
            render_session_limit_hard_reject(message: result[:message], http_status: result[:http_status])
            true
          when :session_limit_exceeded
            issue_session_limit_gate!(return_to: request.fullpath, flow: "in.passkeys.session")
            render json: {
              status: "session_limit_exceeded",
              redirect_url: new_sign_org_in_passkey_path,
            }, status: :ok
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
            redirect_url: sign_org_in_session_path,
          }, status: :ok
        end

        def passkey_bulletin_redirect_url
          sign_org_in_bulletin_path(rd: retrieve_redirect_parameter_for_bulletin, ri: params[:ri])
        end

        def passkey_default_redirect_url
          sign_org_root_path(ri: params[:ri])
        end

        def minimum_response_budget_enabled?
          action_name == "options"
        end
      end
    end
  end
end
