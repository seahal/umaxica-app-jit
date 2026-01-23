# frozen_string_literal: true

require "base64"

module Sign
  module App
    module Configuration
      # PasskeysController handles Passkey registration and management for users.
      #
      # Registration Flow:
      # 1. User visits /configuration/passkeys/new
      # 2. POST /configuration/passkeys/options to get WebAuthn challenge
      # 3. Browser performs navigator.credentials.create()
      # 4. POST /configuration/passkeys/verification with credential + challenge_id
      # 5. Server verifies and creates UserPasskey record
      #
      # CRUD operations:
      # - GET /configuration/passkeys (index)
      # - GET /configuration/passkeys/:id (show)
      # - GET /configuration/passkeys/:id/edit (edit)
      # - PATCH /configuration/passkeys/:id (update - description only)
      # - DELETE /configuration/passkeys/:id (destroy)
      class PasskeysController < ApplicationController
        include Webauthn::Config

        before_action :authenticate_user!
        before_action :set_passkey, only: %i(show edit update destroy)

        # GET /configuration/passkeys
        def index
          @passkeys = policy_scope(current_user.user_passkeys).order(created_at: :desc)
        end

        # GET /configuration/passkeys/:id
        def show
          authorize @passkey
        end

        # GET /configuration/passkeys/new
        def new
          @passkey = current_user.user_passkeys.new
        end

        # GET /configuration/passkeys/:id/edit
        def edit
          authorize @passkey
        end

        # POST /configuration/passkeys/options
        # Generate WebAuthn registration options
        #
        # Response:
        #   {
        #     challenge_id: "abc123",
        #     options: { ... WebAuthn options ... }
        #   }
        def options
          # Build exclude list from existing passkeys
          existing_credentials =
            current_user.user_passkeys.map do |passkey|
              { id: passkey.webauthn_id }
            end

          challenge_id, creation_options = create_registration_challenge(
            resource: current_user,
            exclude_credentials: existing_credentials,
          )

          render json: {
            challenge_id: challenge_id,
            options: creation_options,
          }, status: :ok
        rescue Webauthn::Config::OriginValidationError => e
          Rails.logger.error("WebAuthn origin validation failed: #{e.message}")
          render json: { error: I18n.t("errors.webauthn.origin_invalid") }, status: :forbidden
        rescue StandardError => e
          Rails.logger.error("WebAuthn registration options failed: #{e.message}")
          render json: { error: I18n.t("errors.webauthn.options_failed") }, status: :unprocessable_content
        end

        # POST /configuration/passkeys/verification
        # Verify WebAuthn registration response and create passkey
        #
        # Request body:
        #   {
        #     challenge_id: "abc123",
        #     credential: { id: "...", response: { ... }, ... },
        #     description: "My MacBook" (optional)
        #   }
        #
        # Response on success:
        #   {
        #     status: "ok",
        #     redirect_url: "/configuration/passkeys"
        #   }
        def verification
          challenge_id = params[:challenge_id]

          if challenge_id.blank?
            return render json: {
              error: I18n.t("errors.webauthn.challenge_id_required"),
            }, status: :bad_request
          end

          with_challenge(challenge_id, purpose: :registration) do |challenge|
            # Parse credential from request
            credential = WebAuthn::Credential.from_create(credential_params.to_h)

            # Verify the credential
            credential.verify(
              challenge,
              rp_id: webauthn_rp_id,
              expected_origin: webauthn_origin,
            )

            # Create the passkey record
            passkey = current_user.user_passkeys.new(
              webauthn_id: Base64.urlsafe_encode64(credential.id, padding: false),
              public_key: credential.public_key,
              sign_count: credential.sign_count,
              description: passkey_description,
            )

            authorize passkey, :create?
            passkey.save!

            render json: {
              status: "ok",
              passkey_id: passkey.id,
              redirect_url: sign_app_configuration_passkeys_path,
            }, status: :created
          end
        rescue Webauthn::Config::ChallengeNotFoundError,
               Webauthn::Config::ChallengeExpiredError => e
          Rails.logger.warn("WebAuthn challenge error: #{e.message}")
          render json: { error: I18n.t("errors.webauthn.challenge_invalid") }, status: :bad_request
        rescue Webauthn::Config::ChallengePurposeMismatchError => e
          Rails.logger.warn("WebAuthn challenge purpose mismatch: #{e.message}")
          render json: { error: I18n.t("errors.webauthn.challenge_invalid") }, status: :bad_request
        rescue WebAuthn::Error => e
          Rails.logger.warn("WebAuthn registration failed: #{e.message}")
          render json: { error: I18n.t("errors.webauthn.verification_failed") }, status: :unprocessable_content
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.warn("WebAuthn passkey creation failed: #{e.message}")
          render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_content
        end

        # PATCH/PUT /configuration/passkeys/:id
        def update
          authorize @passkey

          if @passkey.update(update_params)
            respond_to do |format|
              format.html do
                redirect_to sign_app_configuration_passkey_path(@passkey),
                            notice: t("messages.passkey_successfully_updated")
              end
              format.json { render json: { status: "ok" }, status: :ok }
            end
          else
            respond_to do |format|
              format.html { render :edit, status: :unprocessable_content }
              format.json { render json: { errors: @passkey.errors.full_messages }, status: :unprocessable_content }
            end
          end
        end

        # DELETE /configuration/passkeys/:id
        def destroy
          authorize @passkey
          @passkey.destroy!

          respond_to do |format|
            format.html do
              redirect_to sign_app_configuration_passkeys_path,
                          status: :see_other,
                          notice: t("messages.passkey_successfully_destroyed")
            end
            format.json { head :no_content }
          end
        end

        private

        def set_passkey
          @passkey = current_user.user_passkeys.find(params[:id])
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

        def update_params
          params.expect(passkey: [:description])
        end

        def passkey_description
          params[:description].presence || I18n.t("sign.default_passkey_description")
        end
      end
    end
  end
end
