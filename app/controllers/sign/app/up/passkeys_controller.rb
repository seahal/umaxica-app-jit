# frozen_string_literal: true

require "base64"

module Sign
  module App
    module Up
      # PasskeysController handles Passkey registration during the signup flow.
      #
      # After SMS verification, users are required to register a passkey before
      # their account is fully activated.
      #
      # Flow:
      # 1. User completes SMS verification (telephones#update)
      # 2. User is redirected here with verified_user_id in session
      # 3. GET /up/passkeys/new - Show passkey registration form
      # 4. POST /up/passkeys/options - Get WebAuthn challenge
      # 5. Browser performs navigator.credentials.create()
      # 6. POST /up/passkeys/create - Verify credential and create passkey
      # 7. User's account is fully activated and logged in
      class PasskeysController < ApplicationController
        include Sign::Webauthn

        before_action :reject_logged_in_session
        before_action :require_verified_user, except: [:options]

        # GET /up/passkeys/new
        # Show passkey registration form
        def new
          # User is loaded in before_action
        end

        # POST /up/passkeys/options
        # Generate WebAuthn registration options
        def options
          user = load_verified_user
          unless user
            return render json: {
              error: I18n.t("sign.app.registration.passkey.session_expired"),
            }, status: :unauthorized
          end

          challenge_id, creation_options = create_registration_challenge(
            resource: user,
            exclude_credentials: [],
          )

          render json: {
            challenge_id: challenge_id,
            options: creation_options,
          }, status: :ok
        rescue Sign::Webauthn::OriginValidationError => e
          Rails.logger.error("WebAuthn origin validation failed: #{e.message}")
          render json: { error: I18n.t("errors.webauthn.origin_invalid") }, status: :forbidden
        rescue StandardError => e
          Rails.logger.error("WebAuthn registration options failed: #{e.message}")
          render json: { error: I18n.t("errors.webauthn.options_failed") }, status: :unprocessable_content
        end

        # POST /up/passkeys
        # Verify WebAuthn registration response and create passkey
        def create
          challenge_id = require_challenge_id
          return unless challenge_id

          with_challenge(challenge_id, purpose: :registration) do |challenge|
            user = require_verified_user_json
            return unless user

            credential = build_credential

            verify_credential!(credential, challenge)

            passkey = create_passkey!(user, credential)

            complete_signup!(user)

            redirect_url = sign_app_configuration_path(ri: params[:ri])

            render json: {
              status: "ok",
              passkey_id: passkey.id,
              redirect_url: redirect_url,
            }, status: :created
          end
        rescue Sign::Webauthn::ChallengeNotFoundError,
               Sign::Webauthn::ChallengeExpiredError => e
          Rails.logger.warn("WebAuthn challenge error: #{e.message}")
          render json: { error: I18n.t("errors.webauthn.challenge_invalid") }, status: :bad_request
        rescue Sign::Webauthn::ChallengePurposeMismatchError => e
          Rails.logger.warn("WebAuthn challenge purpose mismatch: #{e.message}")
          render json: { error: I18n.t("errors.webauthn.challenge_invalid") }, status: :bad_request
        rescue WebAuthn::Error => e
          Rails.logger.warn("WebAuthn registration failed: #{e.message}")
          render json: { error: I18n.t("errors.webauthn.verification_failed") }, status: :unprocessable_content
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.warn("Passkey creation failed: #{e.message}")
          render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_content
        end

        private

        def require_verified_user
          user = load_verified_user
          return if user

          redirect_to new_sign_app_up_telephone_path,
                      alert: I18n.t("sign.app.registration.passkey.session_expired")
        end

        def load_verified_user
          signup_data = session[:signup_passkey_registration]
          return nil unless signup_data

          user_id = signup_data["user_id"]
          expires_at = signup_data["expires_at"]

          # Check expiry
          return nil if expires_at.to_i < Time.current.to_i

          user = User.find_by(id: user_id)
          return nil unless user

          # Verify user is in the correct state (verified via SMS but not fully active)
          telephone = user.user_telephones.find_by(
            user_telephone_status_id: UserTelephoneStatus::VERIFIED_WITH_SIGN_UP,
          )
          return nil unless telephone

          @verified_user = user
        end

        def require_challenge_id
          challenge_id = params[:challenge_id]
          return challenge_id if challenge_id.present?

          render json: { error: I18n.t("errors.webauthn.challenge_id_required") }, status: :bad_request
          nil
        end

        def require_verified_user_json
          user = load_verified_user
          return user if user

          render json: { error: I18n.t("sign.app.registration.passkey.session_expired") }, status: :unauthorized
          nil
        end

        def build_credential
          WebAuthn::Credential.from_create(credential_params.to_h)
        end

        def verify_credential!(credential, challenge)
          with_webauthn_config do
            credential.verify(
              challenge,
            )
          end
        end

        def create_passkey!(user, credential)
          user.user_passkeys.create!(
            webauthn_id: Base64.urlsafe_encode64(credential.id, padding: false),
            public_key: credential.public_key,
            sign_count: credential.sign_count,
            description: passkey_description,
          )
        end

        def complete_signup!(user)
          finalize_signup(user)
          log_in(user, record_login_audit: true)
          clear_signup_session
        end

        def finalize_signup(user)
          User.transaction do
            # Update user status to fully verified
            user.update!(status_id: UserStatus::VERIFIED_WITH_SIGN_UP)

            # Create audit record
            UserAudit.create!(
              actor_type: "User",
              actor_id: user.id,
              event_id: UserAuditEvent::SIGNED_UP_WITH_TELEPHONE,
              subject_id: user.id.to_s,
              subject_type: "User",
            )
          end
        end

        def clear_signup_session
          session.delete(:signup_passkey_registration)
        end

        def credential_params
          params.expect(
            credential: [
              :id,
              :rawId,
              :type,
              :authenticatorAttachment,
              { transports: [] },
              { response: %i(clientDataJSON attestationObject) },
              { clientExtensionResults: {} },
            ],
          )
        end

        def passkey_description
          params[:description].presence || I18n.t("sign.default_passkey_description")
        end
      end
    end
  end
end
