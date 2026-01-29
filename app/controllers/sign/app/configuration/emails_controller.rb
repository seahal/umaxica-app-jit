# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class EmailsController < ApplicationController
        include Sign::App::EmailRegistrable
        include ::Auth::StepUp

        before_action :authenticate_user!
        before_action -> { require_step_up!(scope: "configuration_email") }

        def index
          @user_emails = current_user.user_emails
        end

        def new
          @user_email = UserEmail.new
        end

        def edit
          @user_email = UserEmail.find_by(public_id: params[:id])
          @verification_token = params[:token]
        end

        def create
          email_params = params.expect(user_email: [:email])
          begin
            initiate_email_verification!(email_params[:email])
            redirect_to edit_sign_app_configuration_email_path(@user_email.id)
          rescue ActiveRecord::RecordInvalid
            render :new, status: :unprocessable_content
          end
        end

        def update
          submitted_code = params[:user_email][:pass_code]
          token = params[:user_email][:token]
          begin
            complete_email_verification!(params[:id], submitted_code, token) do |user_email|
              ActiveRecord::Base.transaction do
                user_email.user = current_user
                user_email.save!

                if current_user.status_id == "UNVERIFIED_WITH_SIGN_UP"
                  current_user.status_id = "VERIFIED_WITH_SIGN_UP"
                  current_user.save!
                end
              end
            end
            redirect_to sign_app_configuration_emails_path,
                        notice: t("sign.app.configuration.email.update.success")
          rescue ActiveRecord::RecordInvalid
            render :edit, status: :unprocessable_content
          rescue ApplicationError => e
            flash[:alert] = e.message
            redirect_to @error_redirect || sign_app_configuration_emails_path
          end
        end
      end
    end
  end
end
