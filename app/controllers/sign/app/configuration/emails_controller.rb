# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class EmailsController < ApplicationController
        include Sign::EmailRegistrable
        include ::Auth::StepUp

        # Skip email flow enforcement - configuration flow is separate from signup flow
        skip_before_action :enforce_email_flow!

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
          email_params = params.expect(user_email: [:address])

          unless initiate_email_verification!(email_params[:address])
            render :new, status: :unprocessable_content
            return
          end

          redirect_to edit_sign_app_configuration_email_path(@user_email.id)
        end

        def update
          @user_email = UserEmail.find_by(public_id: params[:id])
          submitted_code = params.dig(:user_email, :pass_code)
          token = params.dig(:user_email, :token)

          # Validate submitted code presence
          if submitted_code.blank?
            @user_email.errors.add(:pass_code, t("sign.app.configuration.email.update.code_required"))
            render :edit, status: :unprocessable_content
            return
          end

          # Complete email verification
          result =
            complete_email_verification!(params[:id], submitted_code, token) do |user_email|
              ActiveRecord::Base.transaction do
                user_email.user = current_user
                user_email.save!

                if current_user.status_id == UserStatus::UNVERIFIED_WITH_SIGN_UP
                  current_user.status_id = UserStatus::VERIFIED_WITH_SIGN_UP
                  current_user.save!
                end
              end
            end

          if result == :locked
            flash[:alert] = t("sign.app.configuration.email.update.attempts_exceeded")
            redirect_to sign_app_configuration_emails_path
            return
          elsif !result
            render :edit, status: :unprocessable_content
            return
          end

          redirect_to sign_app_configuration_emails_path,
                      notice: t("sign.app.configuration.email.update.success")
        end

        def destroy
          @user_email = current_user.user_emails.find_by!(public_id: params[:id])

          if AuthMethodGuard.last_method?(current_user, excluding: @user_email)
            redirect_to sign_app_configuration_emails_path,
                        alert: t("sign.app.configuration.email.destroy.last_method")
            return
          end

          @user_email.destroy!
          create_audit_event!(UserAuditEvent::EMAIL_REMOVED, subject: @user_email)

          redirect_to sign_app_configuration_emails_path,
                      notice: t("sign.app.configuration.email.destroy.success"),
                      status: :see_other
        end

        private

        def create_audit_event!(event_id, subject:)
          AuditRecord.connected_to(role: :writing) do
            UserAuditEvent.find_or_create_by!(id: event_id)
            UserAuditLevel.find_or_create_by!(id: UserAuditLevel::NEYO)
          end

          UserAudit.create!(
            actor_type: "User",
            actor_id: current_user.id,
            event_id: event_id,
            subject_id: subject.id.to_s,
            subject_type: subject.class.name,
            occurred_at: Time.current,
          )
        end
      end
    end
  end
end
