# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module App
        module Configuration
          class WithdrawalsController < ApplicationController
            auth_required!

            include ::Verification::User
            include Common::Redirect

            before_action :authenticate_user!

            def new
              @schedule_form = Withdrawal::ScheduleForm.new(schedule_params)
              @deactivate_form = Withdrawal::DeactivateForm.new
              @schedule_confirmed = false

              return unless params.key?(:ack_schedule_purge)

              if @schedule_form.valid?
                @schedule_confirmed = true
              else
                render :new, status: :unprocessable_content
              end
            end

            def edit
              unless current_user.deactivated?
                return safe_redirect_to(
                  identity.new_sign_app_configuration_withdrawal_path(ri: params[:ri]),
                  fallback: identity.sign_app_configuration_path(ri: params[:ri]),
                  status: :see_other,
                )
              end

              @recovery_deadline = current_user.deactivated_at + recovery_period
              @recoverable = recoverable_withdrawal?
            end

            def create
              unless recoverable_withdrawal?
                return safe_redirect_to(
                  identity.edit_sign_app_configuration_withdrawal_path(ri: params[:ri]),
                  fallback: identity.new_sign_app_configuration_withdrawal_path(ri: params[:ri]),
                  status: :see_other,
                )
              end

              User.transaction do
                current_user.update!(
                  withdrawal_started_at: nil,
                  deactivated_at: nil,
                  shreddable_at: Float::INFINITY,
                  scheduled_purge_at: nil,
                  withdrawn_at: nil,
                )

                audit_account_recovered!

                Rails.event.notify(
                  "user.withdrawal.recovered",
                  user_id: current_user.id,
                  ip_address: request.remote_ip,
                )
              end

              safe_redirect_to(
                identity.sign_app_configuration_path(ri: params[:ri]),
                fallback: "/configuration",
                status: :see_other,
              )
            end

            def update
              @schedule_form = Withdrawal::ScheduleForm.new(ack_schedule_purge: "1")
              @deactivate_form = Withdrawal::DeactivateForm.new(deactivate_params)

              unless @deactivate_form.valid?
                return render_update_validation_error
              end

              deactivate_user!

              safe_redirect_to(
                identity.edit_sign_app_configuration_path(ri: params[:ri]),
                fallback: identity.sign_app_configuration_path(ri: params[:ri]),
                status: :see_other,
              )
            rescue ActiveRecord::RecordInvalid
              handle_deactivation_failure
            end

            # Reserved for future withdrawal cancellation flow.
            def destroy
              safe_redirect_to(
                identity.edit_sign_app_configuration_withdrawal_path(ri: params[:ri]),
                fallback: identity.sign_app_configuration_path(ri: params[:ri]),
                status: :see_other,
              )
            end

            private

            def recoverable_withdrawal?
              return false if current_user.deactivated_at.blank?

              Time.current < current_user.deactivated_at + recovery_period
            end

            def recovery_period
              31.days
            end

            def schedule_params
              params.permit(:ack_schedule_purge, :ri, :host)
            end

            def deactivate_params
              params.permit(:ack_deactivate_today, :ri, :host)
            end

            def render_update_validation_error
              @schedule_confirmed = true
              render :new, status: :unprocessable_content
            end

            def deactivate_user!
              now = Time.current

              User.transaction do
                assign_withdrawal_schedule!(now)
                current_user.save!
                notify_deactivation!
                audit_account_withdrawn!
              end
            end

            def assign_withdrawal_schedule!(now)
              current_user.withdrawal_started_at ||= now
              current_user.deactivated_at ||= now
              current_user.scheduled_purge_at ||= current_user.deactivated_at + 31.days
              current_user.shreddable_at ||= current_user.scheduled_purge_at
            end

            def notify_deactivation!
              Rails.event.notify(
                "user.withdrawal.deactivated",
                user_id: current_user.id,
                deactivated_at: current_user.deactivated_at,
                shreddable_at: current_user.shreddable_at,
                scheduled_purge_at: current_user.scheduled_purge_at,
                ip_address: request.remote_ip,
              )
            end

            def handle_deactivation_failure
              Rails.event.notify(
                "user.withdrawal.deactivation_failed",
                user_id: current_user.id,
                errors: current_user.errors.full_messages,
                ip_address: request.remote_ip,
              )
              @schedule_confirmed = true
              render :new, status: :unprocessable_content
            end

            def verification_required_action?
              true
            end

            def verification_scope
              "withdrawal"
            end

            def audit_account_withdrawn!
              ActivityRecord.connected_to(role: :writing) do
                UserActivityEvent.find_or_create_by!(id: UserActivityEvent::ACCOUNT_WITHDRAWN)
                UserActivityLevel.find_or_create_by!(id: UserActivityLevel::NOTHING)
              end

              UserActivity.create!(
                actor_type: "User",
                actor_id: current_user.id,
                event_id: UserActivityEvent::ACCOUNT_WITHDRAWN,
                subject_id: current_user.id.to_s,
                subject_type: "User",
                ip_address: request.remote_ip,
                occurred_at: Time.current,
              )
            rescue ActiveRecord::RecordInvalid => e
              Rails.event.error(
                "sign.withdrawal.audit_failed",
                user_id: current_user.id,
                errors: e.record.errors.full_messages,
              )
            end

            def audit_account_recovered!
              ActivityRecord.connected_to(role: :writing) do
                UserActivityEvent.find_or_create_by!(id: UserActivityEvent::ACCOUNT_RECOVERED)
                UserActivityLevel.find_or_create_by!(id: UserActivityLevel::NOTHING)
              end

              UserActivity.create!(
                actor_type: "User",
                actor_id: current_user.id,
                event_id: UserActivityEvent::ACCOUNT_RECOVERED,
                subject_id: current_user.id.to_s,
                subject_type: "User",
                ip_address: request.remote_ip,
                occurred_at: Time.current,
              )
            rescue ActiveRecord::RecordInvalid => e
              Rails.event.error(
                "sign.recovery.audit_failed",
                user_id: current_user.id,
                errors: e.record.errors.full_messages,
              )
            end
          end
        end
      end
    end
  end
end
