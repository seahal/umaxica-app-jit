# app/controllers/sign/app/oauth/googles_controller.rb
module Sign
  module App
    module Oauth
      class GooglesController < ApplicationController
        protect_from_forgery with: :exception

        # POST /oauth/google
        def create
          # RailsのCSRFトークン検証を通る
          redirect_to "/auth/google", allow_other_host: false, status: :see_other
        end

        # GET /auth/google/callback (OmniAuthからのコールバック)
        def callback
          auth_hash = request.env["omniauth.auth"]

          if auth_hash.blank? || !valid_auth_hash?(auth_hash)
            Rails.logger.warn "Invalid or missing auth_hash"
            flash[:alert] = t("sign.app.registration.oauth.google.failure.error")
            redirect_to new_sign_app_registration_path
            return
          end

          begin
            # Google OAuth情報からユーザーを検索または作成
            google_auth = UserGoogleAuth.find_by(token: auth_hash.uid)

            if google_auth
              # 既存のGoogle認証を持つユーザーでログイン
              user = google_auth.user
              Rails.logger.info "Existing Google OAuth user: #{user.id}"
            else
              # 新規ユーザー作成（登録フロー）
              # OAuth経由なのでランダムなパスワードを生成（ユーザーは知る必要なし）
              random_password = SecureRandom.hex(32)
              user = User.create!(
                password: random_password,
                password_confirmation: random_password
              )
              UserGoogleAuth.create!(
                user: user,
                token: auth_hash.uid
              )

              # メールアドレスも保存
              if auth_hash.info.email.present?
                UserEmail.create!(
                  user: user,
                  email: auth_hash.info.email,
                  verified: true # Googleで認証済み
                )
              end

              Rails.logger.info "New Google OAuth user created: #{user.id}"
            end

            # セッション作成
            reset_session
            session[:user_id] = user.id

            flash[:notice] = t("sign.app.registration.oauth.google.callback.success")
            redirect_to sign_app_root_path
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.error "Google OAuth user creation error: #{e.message}"
            flash[:alert] = t("sign.app.registration.oauth.google.failure.error")
            redirect_to new_sign_app_registration_path
          end
        end

        # GET /auth/failure (OmniAuth認証失敗時)
        def failure
          error_message = params[:message] || "unknown_error"
          Rails.logger.error "Google OAuth failure: #{error_message}"
          flash[:alert] = t("sign.app.registration.oauth.google.failure.error")
          redirect_to new_sign_app_authentication_path
        end

        private

        def valid_auth_hash?(auth_hash)
          auth_hash.provider == "google_oauth2" &&
            auth_hash.uid.present?
        end
      end
    end
  end
end
