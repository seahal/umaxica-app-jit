# typed: false
# frozen_string_literal: true

module Sign
  module App
    module Preference
      class EmailController < ApplicationController
        auth_required! only: %i(show update)
        before_action :authenticate_user!, only: %i(show update)
        before_action :set_email_context, only: %i(show edit update)

        def index
          @current_email = stored_email
        end

        def show
        end

        def edit
        end

        def create
          email = email_param
          if email.blank?
            @current_email = stored_email
            return render :index, status: :unprocessable_content
          end

          store_email(email)
          redirect_to(sign_app_preference_email_path(id: "primary"))
        end

        def update
          email = email_param
          return render :edit, status: :unprocessable_content if email.blank?

          store_email(email)
          redirect_to(sign_app_preference_email_path(id: params[:id]))
        end

        private

        def set_email_context
          @current_email = stored_email
        end

        def stored_email
          session[:sign_preference_email].to_s
        end

        def store_email(email)
          session[:sign_preference_email] = email
        end

        def email_param
          params.fetch(:preference_email, {}).permit(:email)[:email].to_s.strip
        end
      end
    end
  end
end
