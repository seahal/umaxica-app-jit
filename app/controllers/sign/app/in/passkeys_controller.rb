# frozen_string_literal: true

require "base64"

module Sign
  module App
    module In
      # PasskeysController handles Passkey-based user authentication.
      #
      # Flow:
      # 1. User visits /in/passkeys/new and enters their email
      # 2. POST /in/passkeys/options with email to get WebAuthn challenge
      # 3. Browser performs navigator.credentials.get()
      # 4. POST /in/passkeys/verification with credential + challenge_id
      # 5. Server verifies and establishes session via Auth::Base#log_in
      #
      # Note: Discoverable credentials (passwordless without identifier) are
      # planned for a future phase. Currently, email is required to look up
      # the user's registered passkeys.
      class PasskeysController < ApplicationController
        include Sign::Webauthn
        include EmailValidation
        include IdentifierDetection
        include SessionLimitGate

        before_action :reject_logged_in_session

        # GET /in/passkeys/new
        # Render login page with email input and passkey button
        def new
        end

        # POST /in/passkeys/options
        # Generate WebAuthn authentication options for the user identified by email
        #
        # Request body:
        #   { email: "user@example.com" }
        #
        # Response:
        #   {
        #     challenge_id: "abc123",
        #     options: { ... WebAuthn options ... }
        #   }
        # rubocop:disable Metrics/AbcSize
        def options
          return unless verify_turnstile_stealth!

          identifier = params[:identifier].to_s.strip
          return render_error("errors.webauthn.pii_required", :unprocessable_content) if identifier.blank?

          user = find_active_user_by_identifier(identifier)
          return render_error("errors.webauthn.no_passkeys_available", :unprocessable_content) unless user
          return render_session_limit_hard_reject if session_limit_hard_reject_for?(user)

          passkeys = user.user_passkeys.where(status_id: UserPasskeyStatus::ACTIVE)
          return render_error("errors.webauthn.no_passkeys_available", :unprocessable_content) if passkeys.empty?

          challenge_id, request_options = generate_challenge_options(passkeys, user)

          render json: {
            challenge_id: challenge_id,
            options: request_options,
          }, status: :ok
        rescue Sign::Webauthn::OriginValidationError => e
          Rails.logger.error("WebAuthn origin validation failed: #{e.message}")
          render_error("errors.webauthn.origin_invalid", :forbidden)
        rescue StandardError => e
          Rails.logger.debug { "ERROR (Options): #{e.message}" }
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

          user_id = challenge_data["user_id"]

          with_challenge(challenge_id, purpose: :authentication) do |challenge|
            verify_and_login(challenge, user_id)
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

        def retrieve_redirect_url
          rd = params[:rd].presence || session.delete(:passkey_return_to)
          return nil unless rd

          begin
            Base64.urlsafe_decode64(rd)
          rescue ArgumentError
            nil
          end
        end

        def find_active_user_by_identifier(identifier)
          user = find_user_by_identifier(identifier)
          user if user&.active?
        end

        def generate_challenge_options(passkeys, user)
          allow_credentials = passkeys.map { |pk| { id: pk.webauthn_id } }
          challenge_id, request_options = create_authentication_challenge(allow_credentials: allow_credentials)

          challenges = session[CHALLENGE_SESSION_KEY]
          challenges[challenge_id]["user_id"] = user.id
          session[CHALLENGE_SESSION_KEY] = challenges

          [challenge_id, request_options]
        end

        def render_error(message_key, status)
          render json: { error: I18n.t(message_key) }, status: status
        end

        def verify_turnstile_stealth!
          result = Jit::Security::TurnstileVerifier.verify(
            token: params["cf-turnstile-response"].to_s,
            remote_ip: request.remote_ip,
            mode: :stealth,
          )
          return true if result["success"]

          render json: { error: I18n.t("turnstile_error") }, status: :unprocessable_content
          false
        end

        def verify_and_login(challenge, user_id)
          credential = build_credential_for_verification
          return unless credential

          passkey = UserPasskey.find_by(webauthn_id: credential.id)

          unless passkey && passkey.user_id == user_id
            Rails.logger.warn("WebAuthn: Credential not found or user mismatch")
            return render_error("errors.webauthn.credential_not_found", :unauthorized)
          end

          unless passkey.user.has_verified_pii?
            Rails.event.notify(
              "authentication.passkey.failed",
              reason: "verified_pii_missing",
              user_id: passkey.user_id,
              ip_address: request.remote_ip,
            )
            return render_error("errors.webauthn.credential_not_found", :unauthorized)
          end

          verify_passkey(credential, passkey, challenge)
          rd = retrieve_redirect_url
          result = complete_sign_in_or_start_mfa!(
            passkey.user, rt: rd, ri: params[:ri], auth_method: "passkey",
          )
          handle_login_result(result)
        end

        def build_credential_for_verification
          WebAuthn::Credential.from_get(credential_params.to_h)
        rescue StandardError => e
          Rails.logger.warn("WebAuthn: Invalid credential payload (#{e.class})")
          render_error("errors.webauthn.credential_not_found", :unauthorized)
          nil
        end

        def verify_passkey(credential, passkey, challenge)
          with_webauthn_config do
            credential.verify(
              challenge,
              public_key: passkey.public_key,
              sign_count: passkey.sign_count,
            )
          end
          # Update sign_count and last_used_at
          passkey.update!(sign_count: credential.sign_count, last_used_at: Time.current)
        end

        def handle_login_result(result)
          case result[:status]
          when :mfa_required
            render json: { status: "mfa_required", redirect_url: result[:redirect_path] }, status: :ok
          when :session_limit_hard_reject
            render_session_limit_hard_reject(message: result[:message], http_status: result[:http_status])
          when :success
            # Check if session is restricted (session limit was exceeded)
            # Gate is already issued by log_in() in Auth::Base
            if result[:restricted]
              render json: {
                status: "session_restricted",
                redirect_url: sign_app_in_session_path,
                message: I18n.t("sign.app.in.session.restricted_notice"),
              }, status: :ok
            else
              render_success(result)
            end
          else
            render_error("errors.login_failed", :unprocessable_content)
          end
        end

        def render_success(result)
          redirect_url = retrieve_redirect_url || sign_app_configuration_path(ri: params[:ri])
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
