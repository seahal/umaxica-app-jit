module Auth
  module App
    module Setting
      class PasskeysController < ApplicationController
        before_action :authenticate_user! # Required in production
        before_action :set_passkey, only: %i[ show edit update destroy ]
        before_action :set_webauthn_user, only: %i[ challenge verify ]

        # POST /v1/passkeys/challenge
        def challenge
          session.delete(:webauthn_user_create_challenge)

          creation_options = WebAuthn::Credential.options_for_create(
            user: {
              id: @webauthn_user.webauthn_id,
              name: (@webauthn_user.try(:email) || "user@example.com").to_s,
              display_name: (@webauthn_user.try(:name) || @webauthn_user.try(:email) ||
                             I18n.t("auth.default_user_name")).to_s
            },
            authenticator_selection: { user_verification: "preferred" },
            attestation: "none"
          )

          session[:webauthn_user_create_challenge] = creation_options.challenge
          render json: creation_options, status: :ok
        rescue WebAuthn::Error => e
          render json: { error: e.message }, status: :unprocessable_content
        end

        # POST /passkeys/verify - Verify WebAuthn registration
        def verify
          challenge = session.delete(:webauthn_user_create_challenge)
          return render(json: { error: I18n.t("errors.unauthorized") }, status: :unauthorized) if challenge.blank?

          credential = WebAuthn::Credential.from_create(passkey_credential_params.to_h)
          credential.verify(challenge)

          passkey = @webauthn_user.user_identity_passkeys.new(
            description: passkey_description,
            external_id: SecureRandom.uuid,
            webauthn_id: webauthn_id_from_credential(credential),
            public_key: credential.public_key,
            sign_count: credential.sign_count
          )

          authorize passkey, :create?
          passkey.save!

          render json: { status: "ok", redirect_url: auth_app_setting_passkeys_path }
        rescue WebAuthn::Error => e
          render json: { error: e.message }, status: :unprocessable_content
        rescue ActiveRecord::RecordInvalid => e
          render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_content
        end

        # GET /passkeys
        def index
          @passkeys = policy_scope(UserIdentityPasskey).order(created_at: :desc)
        end

        # GET /passkeys/1
        def show
          authorize @passkey
        end

        # GET /passkeys/new
        def new
          @passkey = current_user.user_identity_passkeys.new
        end

        # GET /passkeys/1/edit
        def edit
          authorize @passkey
        end

        # POST /passkeys or /passkeys.json
        def create
          @passkey = current_user.user_identity_passkeys.new(passkey_params)
          authorize @passkey

          respond_to do |format|
            if @passkey.save
              format.html {
                redirect_to auth_app_setting_passkey_path(@passkey), notice: t("messages.passkey_successfully_created")
              }
              format.json { render :show, status: :created, location: auth_app_setting_passkey_path(@passkey) }
            else
              format.html { render :new, status: :unprocessable_content }
              format.json { render json: @passkey.errors, status: :unprocessable_content }
            end
          end
        end

        # PATCH/PUT /passkeys/1 or /passkeys/1.json
        def update
          authorize @passkey
          respond_to do |format|
            if @passkey.update(passkey_params)
              format.html {
                redirect_to auth_app_setting_passkey_path(@passkey), notice: t("messages.passkey_successfully_updated")
              }
              format.json { render :show, status: :ok, location: auth_app_setting_passkey_path(@passkey) }
            else
              format.html { render :edit, status: :unprocessable_content }
              format.json { render json: @passkey.errors, status: :unprocessable_content }
            end
          end
        end

        # DELETE /passkeys/1 or /passkeys/1.json
        def destroy
          authorize @passkey
          @passkey.destroy!

          respond_to do |format|
            format.html {
              redirect_to auth_app_setting_passkeys_path, status: :see_other,
                                                          notice: t("messages.passkey_successfully_destroyed")
            }
            format.json { head :no_content }
          end
        end

        private

          # Use callbacks to share common setup or constraints between actions.
          def set_passkey
            @passkey = current_user.user_identity_passkeys.find(params[:id])
          end

          # Only allow a list of trusted parameters through.
          def passkey_params
            params.expect(passkey: [ :description, :public_key, :external_id, :webauthn_id, :sign_count ])
          end

          def authenticate_user!
            # This should be implemented in ApplicationController
            # For now, assuming current_user method exists
          end

          def set_webauthn_user
            return render(json: { error: I18n.t("errors.unauthorized") }, status: :unauthorized) unless current_user

            if current_user.webauthn_id.blank?
              current_user.update!(webauthn_id: SecureRandom.urlsafe_base64(32))
            end
            @webauthn_user = current_user
          end

          def passkey_credential_params
            params.expect(
              credential: [ :id,
                            :rawId,
                            :type,
                            :authenticatorAttachment,
                            { transports: [] },
                            { response: [ :clientDataJSON, :attestationObject ] },
                            { clientExtensionResults: {} } ]
            )
          end

          def passkey_description
            params[:description].presence || I18n.t("sign.default_passkey_description")
          end

          def webauthn_id_from_credential(credential)
            credential.id
          end
      end
    end
  end
end
