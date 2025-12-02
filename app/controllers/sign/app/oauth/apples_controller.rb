# app/controllers/sign/app/oauth/apples_controller.rb
module Sign
  module App
    module Oauth
      class ApplesController < ApplicationController
        protect_from_forgery with: :exception

        # POST /oauth/apple
        def create
          # RailsのCSRFトークン検証を通る
          redirect_to "/auth/apple", allow_other_host: false, status: :see_other
        end

        # GET /auth/apple/callback (OmniAuthからのコールバック)
        def callback
          auth_hash = request.env["omniauth.auth"]

          unless valid_auth_hash?(auth_hash)
            Rails.logger.warn "Invalid or missing auth_hash"
            flash[:alert] = t("sign.app.registration.oauth.apple.failure.error")
            redirect_to new_sign_app_registration_path
            return
          end

          begin
            user = with_identity_writing { find_or_create_user_from(auth_hash) }

            reset_session
            session[:user_id] = user.id

            flash[:notice] = t("sign.app.registration.oauth.apple.callback.success")
            redirect_to sign_app_root_path
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.error "Apple OAuth user creation error: #{e.message}"
            flash[:alert] = t("sign.app.registration.oauth.apple.failure.error")
            redirect_to new_sign_app_registration_path
          end
        end

        # GET /auth/failure (OmniAuth認証失敗時)
        def failure
          error_message = params[:message] || "unknown_error"
          provider = determine_provider

          Rails.logger.error "Apple OAuth failure: #{error_message} (provider=#{provider})"
          flash[:alert] = t("sign.app.registration.oauth.#{provider}.failure.error")
          redirect_to new_sign_app_authentication_path
        end

        private

        def valid_auth_hash?(auth_hash)
          return false if auth_hash.blank?

          auth_hash.provider == "apple" && auth_hash.uid.present?
        end

        def find_or_create_user_from(auth_hash)
          apple_auth = UserIdentityAppleAuth.find_by(token: auth_hash.uid)

          if apple_auth
            sync_user_identity_apple_auth!(apple_auth.user, auth_hash.uid)
            Rails.logger.info "Existing Apple OAuth user: #{apple_auth.user_id}"
            apple_auth.user
          else
            create_user_from_apple(auth_hash)
          end
        end

        def create_user_from_apple(auth_hash)
          random_password = SecureRandom.hex(32)

          User.transaction do
            user = User.create!
            create_identity_secret!(user, random_password)

            sync_user_identity_apple_auth!(user, auth_hash.uid)
            persist_email!(user, auth_hash)

            Rails.logger.info "New Apple OAuth user created: #{user.id}"
            user
          end
        end

        def sync_user_identity_apple_auth!(user, uid)
          return if user.blank? || uid.blank?

          record = UserIdentityAppleAuth.find_or_initialize_by(user: user)
          record.update!(token: uid)
        rescue ActiveRecord::StatementInvalid => e
          Rails.logger.warn("UserIdentityAppleAuth sync skipped: #{e.message}")
        end

        def persist_email!(user, auth_hash)
          email = auth_hash.dig(:info, :email) || auth_hash.info&.email
          return if email.blank?

          normalized_email = email.to_s.downcase

          UserIdentityEmail.find_or_create_by!(user: user, address: normalized_email) do |user_email|
            user_email.confirm_policy = true
          end
        end

        def determine_provider
          provider = params[:strategy] || params[:provider]

          if provider.blank? && (strategy = request.env["omniauth.error.strategy"])
            provider =
              if strategy.respond_to?(:name)
                strategy.name
              elsif strategy.respond_to?(:class)
                strategy.class.name.demodulize
              end
          end

          normalized = provider.to_s.downcase
          return "apple" if normalized == "apple"
          "google"
        end

        def with_identity_writing(&block)
          IdentitiesRecord.connected_to(role: :writing, &block)
        end

        def create_identity_secret!(user, password)
          UserIdentitySecret.create!(
            user: user,
            password: password
          )
        end
      end
    end
  end
end
