# frozen_string_literal: true

module Sign
  module App
    module Up
      class EmailsController < ApplicationController
        include Sign::App::EmailRegistrable
        include Auth::RedirectParameterHandling
        include Auth::PreAuthenticationGuards
        include Auth::SessionAuthentication

        before_action :ensure_not_logged_in_for_registration

        def new
          @user_email = UserEmail.new
        end

        def edit
          @user_email = UserEmail.find_by(id: params["id"])
          if @user_email.blank? ||
              @user_email.otp_expired? ||
              @user_email.user_email_status_id != "UNVERIFIED_WITH_SIGN_UP"
            redirect_params = build_notice_params(t("sign.app.registration.email.edit.session_expired"))
            redirect_to new_sign_app_up_email_path(redirect_params)
          end
        end

        def create
          email_params = params.expect(user_email: [:address, :confirm_policy])
          if initiate_email_verification(email_params[:address])
            redirect_params = build_notice_params(t("sign.app.registration.email.create.verification_code_sent"))
            sanitize_redirect_params!(redirect_params)
            redirect_to edit_sign_app_up_email_path(@user_email.id, redirect_params)
          else
            render :new, status: :unprocessable_content
          end
        end

        def update
          submitted_code = params["user_email"]["pass_code"]
          status =
            complete_email_verification(params["id"], submitted_code) do |user_email|
              ActiveRecord::Base.transaction do
                @user = User.create!(status_id: "VERIFIED_WITH_SIGN_UP")
                user_email.user = @user
                audit = UserAudit.new(actor: @user, event_id: "SIGNED_UP_WITH_EMAIL")
                audit.user = @user
                audit.save!
                user_email.save!
              end
              log_in(@user, record_login_audit: false)
            end

          case status
          when :success
            redirect_with_notice("/", t("sign.app.registration.email.update.success"))
          when :session_expired
            redirect_params = build_alert_params(t("sign.app.registration.email.update.session_expired"))
            redirect_to new_sign_app_up_email_path(redirect_params)
          when :locked
            redirect_params = build_alert_params(t("sign.app.registration.email.update.attempts_exceeded"))
            redirect_to new_sign_app_up_email_path(redirect_params)
          when :invalid_code
            render :edit, status: :unprocessable_content
          end
        end

        private

        def sanitize_redirect_params!(redirect_params)
          return if redirect_params[:rd].blank?

          redirect_params[:rd] = sanitize_encoded_redirect(redirect_params[:rd])
          redirect_params.delete(:rd) if redirect_params[:rd].blank?
        end

        def sanitize_encoded_redirect(encoded_url)
          return if encoded_url.blank?

          decoded_url = Base64.urlsafe_decode64(encoded_url)
          safe_path = safe_internal_path(decoded_url)

          case
          when safe_path
            Base64.urlsafe_encode64(safe_path)
          when safe_external_url?(decoded_url)
            Base64.urlsafe_encode64(decoded_url)
          end
        rescue ArgumentError, URI::InvalidURIError
          nil
        end
      end
    end
  end
end
