# frozen_string_literal: true

module Auth
  module App
    module Setting
      class PasskeysController < ApplicationController
        # GET /passkeys or /passkeys.json
        def index
        end

        # GET /passkeys/1 or /passkeys/1.json
        def show
        end

        # GET /passkeys/new
        def new
        end

        # Post /passkeys/challenge - WebAuthn registration challenge
        def challenge
          current_user = User.last

          creation_options = WebAuthn::Credential.options_for_create(
            user: {
              id: current_user.webauthn_id,
              name: 'sample',
              display_name: 'sample'
            }
          )
          
          session[:webauthn_create_challenge] = creation_options.challenge
          
          render json: {challenge: creation_options.challenge}
        end

        # POST /passkeys/verify - Verify WebAuthn registration
        def verify
          webauthn_credential = WebAuthn::Credential.from_create(params.require(:credential))

          begin
            webauthn_credential.verify(session[:creation_challenge])

            @passkey = current_user.user_passkeys.build(
              webauthn_id: webauthn_credential.id,
              public_key: webauthn_credential.public_key,
              sign_count: webauthn_credential.sign_count,
              description: params[:description] || "Passkey"
            )

            if @passkey.save
              session.delete(:creation_challenge)
              render json: { success: true, message: "Passkey registered successfully" }
            else
              render json: { success: false, errors: @passkey.errors.full_messages }
            end
          rescue WebAuthn::Error => e
            render json: { success: false, error: e.message }, status: :unprocessable_entity
          end
        end

        # GET /passkeys/1/edit
        def edit
          authorize @passkey
        end

        # POST /passkeys or /passkeys.json
        def create
          @passkey = PasskeyForUser.new(passkey_params.merge(user: current_user))
          authorize @passkey

          respond_to do |format|
            if @passkey.save
              format.html { redirect_to @passkey, notice: t("messages.passkey_successfully_created") }
              format.json { render :show, status: :created, location: @passkey }
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
              format.html { redirect_to @passkey, notice: t("messages.passkey_successfully_updated") }
              format.json { render :show, status: :ok, location: @passkey }
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
            format.html { redirect_to passkeys_path, status: :see_other, notice: t("messages.passkey_successfully_destroyed") }
            format.json { head :no_content }
          end
        end

        private

        # Use callbacks to share common setup or constraints between actions.
        def set_passkey
          @passkey = PasskeyForUser.find(params.expect(:id))
        end

        # Only allow a list of trusted parameters through.
        def passkey_params
          params.expect(passkey: [ :description, :public_key, :external_id, :webauthn_id, :sign_count ])
        end

        def authenticate_user!
          # This should be implemented in ApplicationController
          # For now, assuming current_user method exists
        end
      end
    end
  end
end
