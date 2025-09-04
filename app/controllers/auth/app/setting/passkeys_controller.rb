module Auth
  module App
    module Setting
      class PasskeysController < ApplicationController
        before_action :authenticate_user! # ← 本番は必須

        # POST /setting/passkeys/challenge
        def challenge
          session.delete(:webauthn_create_challenge)

          user = User.last
          return render(json: { error: I18n.t("errors.unauthorized") }, status: :unauthorized) unless user

          # webauthn_id を確実に持たせる（初回のみ生成）
          user.update!(webauthn_id: SecureRandom.random_ytes(32)) if user.webauthn_id.blank?

          exclude = if user.respond_to?(:user_passkeys)
                      user.user_passkeys.pluck(:webauthn_id) # = credentialId(base64url)
          else
                      []
          end

          creation_options = WebAuthn::Credential.options_for_create(
            user: {
              id: user.webauthn_id, # gemがJSON化時にbase64url化してくれる
              name: (user.try(:email) || "user@example.com").to_s,
              display_name: (user.try(:name) || user.try(:email) || I18n.t("auth.default_user_name")).to_s
            },
            authenticator_selection: { user_verification: "preferred" },
            attestation: "none",
            exclude: exclude
          )

          session[:webauthn_create_challenge] = creation_options.challenge
          render json: creation_options, status: :ok
        rescue WebAuthn::Error => e
          render json: { error: e.message }, status: :unprocessable_content
        end

        # POST /passkeys/verify - Verify WebAuthn registration
        def verify
          user = User.last

          challenge = session.delete(:webauthn_create_challenge)

          # フロントが { credential: {...} } で送っている前提
          # cred = WebAuthn::Credential.from_create(params.require(:credential).permit!.to_h)

          # チャレンジ・origin・rp_id・署名などをgemが検証
          # cred.verify(challenge)

          # 保存（列名はあなたのモデルに合わせて）
          # passkey = user.user_passkeys.build(
          #   webauthn_id: cred.id,         # credentialId（base64url文字列）
          #   public_key:  cred.public_key, # OpenSSL::PKey で検証に使う
          #   sign_count:  cred.sign_count,
          #   description: params[:description].presence || I18n.t("auth.default_passkey_name"),
          # # aaguid: cred.aaguid # 欲しければ
          #   )
          render json: { status: "ok" }
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
