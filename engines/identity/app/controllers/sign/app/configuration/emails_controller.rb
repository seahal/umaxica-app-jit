# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module App
        module Configuration
          class EmailsController < ApplicationController
            auth_required!

            include ::Verification::User

            before_action :authenticate_user!

            def index
              @user_emails = current_user.user_emails
            end

            def edit
              @user_email = current_user.user_emails.find_by!(public_id: params[:id])
            end

            def destroy
              @user_email = current_user.user_emails.find_by!(public_id: params[:id])

              if @user_email.undeletable?
                redirect_to(
                  identity.sign_app_configuration_emails_path,
                  alert: t("sign.app.configuration.email.destroy.protected"),
                )
                return
              end

              unless AuthMethodGuard.can_remove_email?(current_user, @user_email)
                redirect_to(
                  identity.sign_app_configuration_emails_path,
                  alert: t("sign.app.configuration.email.destroy.last_method"),
                )
                return
              end

              @user_email.destroy!
              create_audit_event!(UserActivityEvent::EMAIL_REMOVED, subject: @user_email)

              redirect_to(
                identity.sign_app_configuration_emails_path,
                notice: t("sign.app.configuration.email.destroy.success"),
                status: :see_other,
              )
            end

            private

            def create_audit_event!(event_id, subject:)
              ActivityRecord.connected_to(role: :writing) do
                UserActivityEvent.find_or_create_by!(id: event_id)
                UserActivityLevel.find_or_create_by!(id: UserActivityLevel::NOTHING)
              end

              UserActivity.create!(
                actor_type: "User",
                actor_id: current_user.id,
                event_id: event_id,
                subject_id: subject.id.to_s,
                subject_type: subject.class.name,
                occurred_at: Time.current,
              )
            end

            def verification_required_action?
              true
            end

            def verification_scope
              "configuration_email"
            end
          end
        end
      end
    end
  end
end
