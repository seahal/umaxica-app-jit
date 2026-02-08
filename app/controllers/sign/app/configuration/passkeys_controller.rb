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
        include ::Auth::StepUp
        include Sign::Webauthn

        before_action :authenticate_user!
        before_action -> { require_step_up!(scope: "configuration_passkey") },
                      only: %i(new options verification edit update destroy)
        before_action :ensure_verified_recovery_identity_for_registration!, only: [:new]
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

        # POST /configuration/passkeys
        def create
          @passkey = current_user.user_passkeys.new(create_params)
          authorize @passkey, :create?

          if @passkey.save
            render plain: "ok", status: :created
          else
            render plain: @passkey.errors.full_messages.join("\n"), status: :unprocessable_entity
          end
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
        rescue Sign::Webauthn::OriginValidationError => e
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

            # Verify the credential with per-request configuration
            with_webauthn_config do
              credential.verify(
                challenge,
              )
            end

            # Create the passkey record
            passkey = current_user.user_passkeys.new(
              webauthn_id: credential.id,
              public_key: credential.public_key,
              sign_count: credential.sign_count,
              description: passkey_description,
            )

            authorize passkey, :create?
            passkey.save!

            issue_emergency_key!

            render json: {
              status: "ok",
              redirect_url: sign_app_configuration_emergency_key_path(ri: params[:ri]),
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
        rescue ActiveRecord::RecordNotUnique
          render json: { error: I18n.t("errors.webauthn.credential_already_registered") }, status: :conflict
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.warn("WebAuthn passkey creation failed: #{e.message}")
          render plain: e.record.errors.full_messages.join("\n"), status: :unprocessable_entity
        end

        # PATCH/PUT /configuration/passkeys/:id
        def update
          authorize @passkey

          begin
            @passkey.update!(update_params)
            respond_to do |format|
              format.html do
                redirect_to sign_app_configuration_passkey_path(@passkey),
                            notice: t("messages.passkey_successfully_updated")
              end
              format.json { render json: { status: "ok" }, status: :ok }
            end
          rescue ActiveRecord::RecordInvalid
            respond_to do |format|
              format.html { render :edit, status: :unprocessable_content }
              format.json { render json: { errors: @passkey.errors.full_messages }, status: :unprocessable_content }
            end
          end
        end

        # DELETE /configuration/passkeys/:id
        def destroy
          authorize @passkey

          # Prevent deleting the last passkey
          if current_user.user_passkeys.active.count <= 1
            respond_to do |format|
              format.html do
                redirect_to sign_app_configuration_passkeys_path,
                            status: :see_other,
                            alert: t("messages.cannot_delete_last_passkey")
              end
              format.json do
                render json: { error: t("messages.cannot_delete_last_passkey") },
                       status: :unprocessable_content
              end
            end
            return
          end

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
          @passkey = current_user.user_passkeys.find_by!(public_id: params[:public_id])
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
          key = params.key?(:user_passkey) ? :user_passkey : :passkey
          params.expect(key => [:description])
        end

        def create_params
          params.fetch(:user_passkey, {}).permit(:webauthn_id, :public_key, :sign_count, :description, :external_id)
        end

        def issue_emergency_key!
          result = UserSecrets::IssueRecovery.call(actor: current_user, user: current_user)
          session[:recovery_secret_raw] = result.raw_secret
        end

        def ensure_verified_recovery_identity_for_registration!
          return if current_user.has_verified_recovery_identity?

          render plain: User::RECOVERY_IDENTITY_REQUIRED_MESSAGE, status: :forbidden
        end

        def passkey_description
          params[:description].presence || I18n.t("sign.default_passkey_description")
        end
      end
    end
  end
end
