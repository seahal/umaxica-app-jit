# frozen_string_literal: true

module Sign
  module Org
    module In
      # PasskeysController handles Passkey-based staff authentication.
      #
      # Flow:
      # 1. Staff visits /in/passkeys/new and enters their staff_code or email
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
        include SessionLimitGate

        before_action :reject_logged_in_session

        guest_only!

        # GET /in/passkeys/new
        # Render login page with identifier input and passkey button
        def new
        end

        # POST /in/passkeys/options
        # Generate WebAuthn authentication options for the staff identified by email or staff_code
        #
        # Request body:
        #   { identifier: "staff@example.com" } or { identifier: "ab12cd34" }
        #
        # Response:
        #   {
        #     challenge_id: "abc123",
        #     options: { ... WebAuthn options ... }
        #   }
        # rubocop:disable Metrics/AbcSize
        def options
          identifier = params[:identifier].to_s.strip.downcase
          return render_error("errors.webauthn.identifier_required", :unprocessable_content) if identifier.blank?

          staff = find_active_staff(identifier)
          return render_error("errors.webauthn.no_passkeys_available", :unprocessable_content) unless staff

          passkeys = staff.staff_passkeys.where(staff_passkey_status_id: "ACTIVE")
          return render_error("errors.webauthn.no_passkeys_available", :unprocessable_content) if passkeys.empty?

          challenge_id, request_options = generate_challenge_options(passkeys, staff)

          render json: {
            challenge_id: challenge_id,
            options: request_options,
          }, status: :ok
        rescue Sign::Webauthn::OriginValidationError => e
          Rails.logger.error("WebAuthn origin validation failed: #{e.message}")
          render_error("errors.webauthn.origin_invalid", :forbidden)
        rescue StandardError => e
          Rails.logger.error("WebAuthn authentication options failed: #{e.message}")
          render_error("errors.webauthn.options_failed", :unprocessable_content)
        end

        # rubocop:enable Metrics/AbcSize

        # POST /in/passkeys/verification
        # Verify WebAuthn authentication response and establish session
        #
        # Request body:
        #   {
        #     challenge_id: "abc123",
        #     credential: { id: "...", response: { ... }, ... }
        #   }
        #
        # Response on success:
        #   {
        #     status: "ok",
        #     access_token: "...",
        #     token_type: "Bearer",
        #     expires_in: 3600,
        #     redirect_url: "/"
        #   }
        # rubocop:disable Metrics/AbcSize
        def verification
          challenge_id = params[:challenge_id]
          return render_error("errors.webauthn.challenge_id_required", :bad_request) if challenge_id.blank?

          challenge_data = peek_challenge(challenge_id)
          return render_error("errors.webauthn.challenge_invalid", :bad_request) unless challenge_data

          staff_id = challenge_data["staff_id"]

          with_challenge(challenge_id, purpose: :authentication) do |challenge|
            verify_and_login(challenge, staff_id)
          end
        rescue Sign::Webauthn::ChallengeNotFoundError, Sign::Webauthn::ChallengeExpiredError => e
          Rails.logger.warn("WebAuthn challenge error: #{e.message}")
          render_error("errors.webauthn.challenge_invalid", :bad_request)
        rescue Sign::Webauthn::ChallengePurposeMismatchError => e
          Rails.logger.warn("WebAuthn challenge purpose mismatch: #{e.message}")
          render_error("errors.webauthn.challenge_invalid", :bad_request)
        rescue WebAuthn::SignCountVerificationError => e
          Rails.logger.warn("WebAuthn sign count verification failed: #{e.message}")
          render_error("errors.webauthn.sign_count_mismatch", :unauthorized)
        rescue WebAuthn::Error => e
          Rails.logger.warn("WebAuthn authentication failed: #{e.message}")
          render_error("errors.webauthn.verification_failed", :unauthorized)
        end

        # rubocop:enable Metrics/AbcSize

        private

        def credential_params
          params.expect(
            credential: [
              :id,
              :rawId,
              :type,
              :authenticatorAttachment,
              { response: %i(clientDataJSON authenticatorData signature userHandle) },
              { clientExtensionResults: {} },
            ],
          )
        end

        def find_staff_by_identifier(identifier)
          # Try to find by email first
          staff_email = StaffEmail.find_by(address: identifier)
          return staff_email.staff if staff_email

          # Try to find by staff_code (public_id)
          Staff.find_by(public_id: identifier)
        end

        def retrieve_redirect_url
          rd = params[:rd].presence || session.delete(:passkey_return_to)
          return nil unless rd

          begin
            Base64.urlsafe_decode64(rd)
          rescue ArgumentError
            nil
          end
        end

        def find_active_staff(identifier)
          staff = find_staff_by_identifier(identifier)
          staff if staff&.active?
        end

        def generate_challenge_options(passkeys, staff)
          allow_credentials = passkeys.map { |pk| { id: pk.webauthn_id } }
          challenge_id, request_options = create_authentication_challenge(allow_credentials: allow_credentials)

          challenges = session[CHALLENGE_SESSION_KEY]
          challenges[challenge_id]["staff_id"] = staff.id
          session[CHALLENGE_SESSION_KEY] = challenges

          [challenge_id, request_options]
        end

        def render_error(message_key, status)
          render json: { error: I18n.t(message_key) }, status: status
        end

        def verify_and_login(challenge, staff_id)
          credential = WebAuthn::Credential.from_get(credential_params.to_h)
          passkey = StaffPasskey.find_by(webauthn_id: credential.id)

          unless passkey && passkey.staff_id == staff_id
            Rails.logger.warn("WebAuthn: Credential not found or staff mismatch")
            return render_error("errors.webauthn.credential_not_found", :unauthorized)
          end

          verify_passkey(credential, passkey, challenge)
          result = log_in(passkey.staff, record_login_audit: true)
          handle_login_result(result)
        end

        def verify_passkey(credential, passkey, challenge)
          credential.verify(
            challenge,
            public_key: passkey.public_key,
            sign_count: passkey.sign_count,
            rp_id: webauthn_rp_id,
            expected_origin: webauthn_origin,
          )
          passkey.update!(sign_count: credential.sign_count)
        end

        def handle_login_result(result)
          case result[:status]
          when :totp_required
            render json: { status: "totp_required", redirect_url: new_sign_org_in_totp_path }, status: :ok
          when :session_limit_exceeded
            issue_session_limit_gate!(return_to: request.fullpath, flow: "in.passkeys.session")
            render json: {
              status: "session_limit_exceeded",
              redirect_url: edit_sign_org_in_passkey_sessions_path(passkey_id: "_"),
            }, status: :ok
          when :success
            render_success(result)
          else
            render_error("errors.login_failed", :unprocessable_content)
          end
        end

        def render_success(result)
          redirect_url = retrieve_redirect_url || sign_org_root_path
          render json: {
            status: "ok",
            access_token: result[:access_token],
            token_type: result[:token_type],
            expires_in: result[:expires_in],
            redirect_url: redirect_url,
          }, status: :ok
        end
      end
    end
  end
end
