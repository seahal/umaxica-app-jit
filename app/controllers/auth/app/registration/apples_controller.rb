module Auth
  module App
    module Registration
      class ApplesController < ApplicationController
        rescue_from "OmniAuth::Error" do |exception|
          Rails.logger.error "OmniAuth Error: #{exception.message}"
          flash[:error] = t("messages.auth_error_occurred")
          redirect_to new_auth_app_registration_path
        end

        def new
          redirect_to "/auth/apple", allow_other_host: true
        end

        def create
          auth_hash = request.env["omniauth.auth"]

          if auth_hash.present? && valid_auth_hash?(auth_hash)
            begin
              @user_info = extract_user_info(auth_hash)

              # Implement user registration process here
              # Example: User.find_or_create_by(email: @user_info[:email]) do |user|
              #       user.name = @user_info[:name]
              #       user.provider = @user_info[:provider]
              #       user.uid = @user_info[:uid]
              #     end

              Rails.logger.info "Apple OAuth successful for email: #{@user_info[:email]}"
              render :success
            rescue => e
              Rails.logger.error "User registration error: #{e.message}"
              flash[:error] = t("messages.user_registration_error")
              redirect_to new_auth_app_registration_path
            end
          else
            # Handle authentication failure
            Rails.logger.warn "Invalid or missing auth_hash"
            flash[:error] = t("messages.access_blocked_auth_error")
            redirect_to new_auth_app_registration_path
          end
        end

        private

        def extract_user_info(auth_hash)
          {
            provider: auth_hash.provider,
            uid: auth_hash.uid,
            email: auth_hash.info.email,
            name: auth_hash.info.name,
            first_name: auth_hash.info.first_name,
            last_name: auth_hash.info.last_name
          }
        end

        def valid_auth_hash?(auth_hash)
          auth_hash.provider == "apple" &&
            auth_hash.uid.present? &&
            auth_hash.info.email.present?
        end
      end
    end
  end
end
