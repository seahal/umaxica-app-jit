# app/controllers/sign/app/oauth/googles_controller.rb
module Sign
  module App
    module Oauth
      class GooglesController < ApplicationController
        protect_from_forgery with: :exception

        # POST /oauth/google
        def create
          # Pass Rails CSRF token verification
          redirect_to "/auth/google", allow_other_host: false, status: :see_other
        end

        # GET /auth/google/callback (Callback from OmniAuth)
        def callback
          auth_hash = request.env["omniauth.auth"]

          unless valid_auth_hash?(auth_hash)
            Rails.event.notify("oauth.google.invalid_auth_hash")
            flash[:alert] = t("sign.app.registration.oauth.google.failure.error")
            redirect_to new_sign_app_registration_path
            return
          end

          begin
            user = with_identity_writing { find_or_create_user_from(auth_hash) }

            reset_session
            session[:user_id] = user.id

            flash[:notice] = t("sign.app.registration.oauth.google.callback.success")
            redirect_to sign_app_root_path
          rescue ActiveRecord::RecordInvalid => e
            Rails.event.notify("oauth.google.user_creation_error", error_message: e.message)
            flash[:alert] = t("sign.app.registration.oauth.google.failure.error")
            redirect_to new_sign_app_registration_path
          end
        end

        # GET /auth/failure (When OmniAuth authentication fails)
        def failure
          error_message = params[:message] || "unknown_error"
          Rails.event.notify("oauth.google.failure", error_message: error_message)
          flash[:alert] = t("sign.app.registration.oauth.google.failure.error")
          redirect_to new_sign_app_authentication_path
        end

        private

        def valid_auth_hash?(auth_hash)
          auth_hash.present? &&
            auth_hash.provider == "google_oauth2" &&
            auth_hash.uid.present?
        end

        def find_or_create_user_from(auth_hash)
          google_auth = UserIdentityGoogleAuth.find_by(token: auth_hash.uid)

          if google_auth
            Rails.event.notify("oauth.google.existing_user", user_id: google_auth.user_id)
            sync_user_identity_google_auth!(google_auth.user, auth_hash.uid)
            persist_email!(google_auth.user, auth_hash)
            google_auth.user
          else
            create_user_from_google(auth_hash)
          end
        end

        def create_user_from_google(auth_hash)
          random_password = SecureRandom.hex(32)

          User.transaction do
            user = User.create!
            create_identity_secret!(user, random_password)

            sync_user_identity_google_auth!(user, auth_hash.uid)
            persist_email!(user, auth_hash)

            Rails.event.notify("oauth.google.new_user", user_id: user.id)
            user
          end
        end

        def persist_email!(user, auth_hash)
          email = auth_hash.dig(:info, :email) || auth_hash.info&.email
          return if email.blank?

          normalized_email = email.to_s.downcase

          UserIdentityEmail.find_or_create_by!(user: user, address: normalized_email) do |user_email|
            user_email.confirm_policy = true
          end
        end

        def sync_user_identity_google_auth!(user, uid)
          return if user.blank? || uid.blank?

          record = UserIdentityGoogleAuth.find_or_initialize_by(user: user)
          record.update!(token: uid)
        rescue ActiveRecord::StatementInvalid => e
          Rails.event.notify("oauth.google.sync_skipped", error_message: e.message)
        end

        def with_identity_writing(&block)
          IdentitiesRecord.connected_to(role: :writing, &block)
        end

        def create_identity_secret!(user, password)
          UserIdentitySecret.create!(
            user: user,
            name: "OAuth Password",
            password: password
          )
        end
      end
    end
  end
end
