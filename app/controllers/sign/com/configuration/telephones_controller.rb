# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      class TelephonesController < ApplicationController
        auth_required!

        include Sign::TelephoneRegistrable
        include ::Verification::User

        before_action :authenticate_customer!

        def index
          @user_telephones = current_customer.user_telephones
        end

        def new
          @user_telephone = UserTelephone.new
        end

        def edit
          @user_telephone = current_customer.user_telephones.find_by!(public_id: params[:id])
        end

        def create
          user = current_customer
          return head :unauthorized if user.blank?

          tel_params = params.expect(user_telephone: [:raw_number, :number])
          number = tel_params[:raw_number] || tel_params[:number]
          if initiate_telephone_verification(user, number, auto_accept_confirmations: true)
            redirect_to(edit_sign_com_configuration_telephone_path(@user_telephone.id, ri: params[:ri]))
          else
            render :new, status: :unprocessable_content
          end
        end

        def destroy
          telephone = current_customer.user_telephones.find_by!(public_id: params[:id])

          unless AuthMethodGuard.can_remove_telephone?(current_customer, telephone)
            redirect_to(
              sign_com_configuration_telephones_path(ri: params[:ri]),
              alert: t("sign.app.configuration.telephone.destroy.last_method"),
            )
            return
          end

          telephone.destroy!
          create_audit_event!(UserActivityEvent::TELEPHONE_REMOVED, subject: telephone)

          redirect_to(
            sign_com_configuration_telephones_path(ri: params[:ri]),
            notice: t("sign.app.configuration.telephone.destroy.success"),
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
            actor_id: current_customer.id,
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
          "configuration_telephone"
        end
      end
    end
  end
end
