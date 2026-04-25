# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module Com
        module Configuration
          class WithdrawalsController < ApplicationController
            auth_required!

            include ::Verification::User
            include Common::Redirect

            before_action :authenticate_customer!

            def new
              @schedule_form = Jit::Identity::Sign::App::Configuration::Withdrawal::ScheduleForm.new(schedule_params)
              @deactivate_form = Jit::Identity::Sign::App::Configuration::Withdrawal::DeactivateForm.new
              @schedule_confirmed = false

              return unless params.key?(:ack_schedule_purge)

              if @schedule_form.valid?
                @schedule_confirmed = true
              else
                render :new, status: :unprocessable_content
              end
            end

            def edit
              unless current_customer.deactivated?
                return safe_redirect_to(
                  identity.new_sign_com_configuration_withdrawal_path(ri: params[:ri]),
                  fallback: identity.sign_com_configuration_path(ri: params[:ri]),
                  status: :see_other,
                )
              end

              @recovery_deadline = current_customer.deactivated_at + recovery_period
              @recoverable = recoverable_withdrawal?
            end

            def create
              unless recoverable_withdrawal?
                return safe_redirect_to(
                  identity.edit_sign_com_configuration_withdrawal_path(ri: params[:ri]),
                  fallback: identity.new_sign_com_configuration_withdrawal_path(ri: params[:ri]),
                  status: :see_other,
                )
              end

              Customer.transaction do
                current_customer.update!(
                  withdrawal_started_at: nil,
                  deactivated_at: nil,
                  shreddable_at: Float::INFINITY,
                  scheduled_purge_at: nil,
                  withdrawn_at: nil,
                )

                Rails.event.notify(
                  "customer.withdrawal.recovered",
                  customer_id: current_customer.id,
                  ip_address: request.remote_ip,
                )
              end

              safe_redirect_to(
                identity.sign_com_configuration_path(ri: params[:ri]),
                fallback: "/configuration",
                status: :see_other,
              )
            end

            def update
              @schedule_form = Jit::Identity::Sign::App::Configuration::Withdrawal::ScheduleForm.new(ack_schedule_purge: "1")
              @deactivate_form = Jit::Identity::Sign::App::Configuration::Withdrawal::DeactivateForm.new(deactivate_params)

              unless @deactivate_form.valid?
                return render_update_validation_error
              end

              deactivate_user!

              safe_redirect_to(
                identity.edit_sign_com_configuration_path(ri: params[:ri]),
                fallback: identity.sign_com_configuration_path(ri: params[:ri]),
                status: :see_other,
              )
            rescue ActiveRecord::RecordInvalid
              handle_deactivation_failure
            end

            def destroy
              safe_redirect_to(
                identity.edit_sign_com_configuration_withdrawal_path(ri: params[:ri]),
                fallback: identity.sign_com_configuration_path(ri: params[:ri]),
                status: :see_other,
              )
            end

            private

            def recoverable_withdrawal?
              return false if current_customer.deactivated_at.blank?

              Time.current < current_customer.deactivated_at + recovery_period
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

              Customer.transaction do
                assign_withdrawal_schedule!(now)
                current_customer.save!
                notify_deactivation!
              end
            end

            def assign_withdrawal_schedule!(now)
              current_customer.withdrawal_started_at ||= now
              current_customer.deactivated_at ||= now
              current_customer.scheduled_purge_at ||= current_customer.deactivated_at + 31.days
              current_customer.shreddable_at ||= current_customer.scheduled_purge_at
            end

            def notify_deactivation!
              Rails.event.notify(
                "customer.withdrawal.deactivated",
                customer_id: current_customer.id,
                deactivated_at: current_customer.deactivated_at,
                shreddable_at: current_customer.shreddable_at,
                scheduled_purge_at: current_customer.scheduled_purge_at,
                ip_address: request.remote_ip,
              )
            end

            def handle_deactivation_failure
              Rails.event.notify(
                "customer.withdrawal.deactivation_failed",
                customer_id: current_customer.id,
                errors: current_customer.errors.full_messages,
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
          end
        end
      end
    end
  end
end
