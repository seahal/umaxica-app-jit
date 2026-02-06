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
          tel_params = params.expect(user_telephone: [:telephone_number])
          if initiate_telephone_verification(tel_params[:telephone_number])
            redirect_to edit_sign_app_configuration_telephone_path(@user_telephone.id)
          else
            render :new, status: :unprocessable_content
          end
        end

        def update
          submitted_code = params[:user_telephone][:pass_code]
          status =
            complete_telephone_verification(params[:id], submitted_code) do |user_telephone|
              user_telephone.user = current_user
              user_telephone.save!
            end

          if status == :success
            redirect_to sign_app_configuration_telephones_path,
                        notice: t("sign.app.configuration.telephone.update.success")
          else
            render :edit, status: :unprocessable_content
          end
        end

        def destroy
          @user_telephone = current_user.user_telephones.find(params[:id])

          if AuthMethodGuard.last_method?(current_user, excluding: @user_telephone)
            redirect_to sign_app_configuration_telephones_path,
                        alert: t("sign.app.configuration.telephone.destroy.last_method")
            return
          end

          @user_telephone.destroy!
          create_audit_event!(UserAuditEvent::TELEPHONE_REMOVED, subject: @user_telephone)

          redirect_to sign_app_configuration_telephones_path,
                      notice: t("sign.app.configuration.telephone.destroy.success"),
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
