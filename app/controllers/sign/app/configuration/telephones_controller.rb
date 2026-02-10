# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class TelephonesController < ApplicationController
        include Sign::TelephoneRegistrable
        include ::Auth::StepUp

        before_action :authenticate_user!
        before_action -> { require_step_up!(scope: "configuration_telephone") }

        def index
          @user_telephones = current_user.user_telephones
        end

        def new
          @user_telephone = UserTelephone.new
        end

        def edit
          @user_telephone = UserTelephone.find_by(id: params[:id])
        end

        def create
          user = current_user
          return head :unauthorized if user.blank?

          tel_params = params.expect(user_telephone: [:number])
          if initiate_telephone_verification(user, tel_params[:number])
            redirect_to edit_sign_app_configuration_telephone_path(@user_telephone.id)
          else
            render :new, status: :unprocessable_content
          end
        end

        def destroy
          telephone = current_user.user_telephones.find_by!(public_id: params[:id])

          if AuthMethodGuard.last_method?(current_user, excluding: telephone)
            redirect_to sign_app_configuration_telephones_path,
                        alert: t("sign.app.configuration.telephone.destroy.last_method")
            return
          end

          telephone.destroy!
          create_audit_event!(UserAuditEvent::TELEPHONE_REMOVED, subject: telephone)

          redirect_to sign_app_configuration_telephones_path,
                      notice: t("sign.app.configuration.telephone.destroy.success"),
                      status: :see_other
        end

        private

        def create_audit_event!(event_id, subject:)
          ActivityRecord.connected_to(role: :writing) do
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
