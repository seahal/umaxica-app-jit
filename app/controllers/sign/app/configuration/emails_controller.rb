# frozen_string_literal: true

module Sign
  module App
    class Configuration::EmailsController < ApplicationController
      include Sign::App::EmailRegistrable

      before_action :authenticate_user! # Ensure user is logged in

      def index
        @user_emails = current_user.user_emails
      end

      def new
        @user_email = UserEmail.new
      end

      def edit
        @user_email = UserEmail.find_by(id: params["id"])
      end

      def create
        # Note: address param naming might differ in existing form, adjust if needed
        if initiate_email_verification(params[:user_email][:address])
          redirect_to edit_sign_app_configuration_email_path(@user_email.id)
        else
          render :new, status: :unprocessable_content
        end
      end

      def update
        status =
          complete_email_verification(params["id"], params[:user_email][:pass_code]) do |user_email|
            user_email.user = current_user
            user_email.save!
          end

        case status
        when :success
          redirect_to sign_app_configuration_emails_path, notice: t("sign.app.configuration.email.update.success")
        when :invalid_code
          render :edit, status: :unprocessable_content
        else
          redirect_to new_sign_app_configuration_email_path
        end
      end
    end
  end
end
