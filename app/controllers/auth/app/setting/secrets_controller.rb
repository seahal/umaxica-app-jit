# TODO: Refactor to use UserIdentitySecretsController
# all methods are required for user authentication

module Auth
  module App
    module Setting
      class SecretsController < ApplicationController
        before_action :authenticate_user!
        before_action :set_secret, only: %i[show edit update destroy]

        def index
          @secrets = UserIdentitySecret.where(user: current_user).order(created_at: :desc)
        end

        def show
        end

        def new
          @secret = current_user.user_identity_secrets.new
        end

        def edit
        end

        def create
          @secret = current_user.user_identity_secrets.new(secret_params)

          respond_to do |format|
            if @secret.save
              format.html {
                redirect_to auth_app_setting_secret_path(@secret), notice: t("messages.secret_successfully_created")
              }

            else
              format.html { render :new, status: :unprocessable_content }
            end
          end
        end

        def update
          respond_to do |format|
            if @secret.update(secret_params)
              format.html {
                redirect_to auth_app_setting_secret_path(@secret), notice: t("messages.secret_successfully_updated")
              }
            else
              format.html { render :edit, status: :unprocessable_content }
            end
          end
        end

        def destroy
          @secret.destroy!

          respond_to do |format|
            format.html {
              redirect_to auth_app_setting_secrets_path, status: :see_other,
                                                         notice: t("messages.secret_successfully_destroyed")
            }
          end
        end

        private

          def set_secret
            @secret = current_user.user_identity_secrets.find(params[:id])
          end

          def secret_params
            params.expect(user_identity_secret: [ :name, :value ])
          end
      end
    end
  end
end
