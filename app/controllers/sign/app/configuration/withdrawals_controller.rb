# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class WithdrawalsController < ApplicationController
        include ::Auth::StepUp
        include Common::Redirect

        before_action :authenticate_user!
        before_action -> { require_step_up!(scope: "withdrawal") }

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

        def update
          @schedule_form = Withdrawal::ScheduleForm.new(ack_schedule_purge: "1")
          @deactivate_form = Withdrawal::DeactivateForm.new(deactivate_params)

          unless @deactivate_form.valid?
            @schedule_confirmed = true
            return render :new, status: :unprocessable_content
          end

          now = Time.current

          User.transaction do
            current_user.withdrawal_started_at ||= now
            current_user.deactivated_at ||= now
            current_user.scheduled_purge_at ||= current_user.deactivated_at + 31.days
            current_user.save!

            Rails.event.notify(
              "user.withdrawal.deactivated",
              user_id: current_user.id,
              deactivated_at: current_user.deactivated_at,
              scheduled_purge_at: current_user.scheduled_purge_at,
              ip_address: request.remote_ip,
            )
          end

          safe_redirect_to(
            edit_sign_app_configuration_path(ri: params[:ri]),
            fallback: sign_app_configuration_path(ri: params[:ri]),
            status: :see_other,
          )
        rescue ActiveRecord::RecordInvalid
          Rails.event.notify(
            "user.withdrawal.deactivation_failed",
            user_id: current_user.id,
            errors: current_user.errors.full_messages,
            ip_address: request.remote_ip,
          )
          @schedule_confirmed = true
          render :new, status: :unprocessable_content
        end

        private

        def schedule_params
          params.permit(:ack_schedule_purge)
        end

        def deactivate_params
          params.permit(:ack_deactivate_today)
        end
      end
    end
  end
end
