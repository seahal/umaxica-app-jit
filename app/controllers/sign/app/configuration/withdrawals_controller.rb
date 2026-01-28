# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class WithdrawalsController < ApplicationController
        before_action :authenticate_user!

        def show
        end

        def new
        end

        def edit
        end

        def create
          current_user.request_withdrawal!
          process_withdrawal_success
        end

        def update
          current_user.request_withdrawal!
          process_withdrawal_success
        end

        private

          def process_withdrawal_success
            User.transaction do
              Rails.event.notify(
                "user.withdrawal.initiated",
                user_id: current_user.id,
                withdraw_requested_at: current_user.withdraw_requested_at,
                withdraw_scheduled_at: current_user.withdraw_scheduled_at,
                withdraw_cooldown_until: current_user.withdraw_cooldown_until,
                status: current_user.status_id,
                ip_address: request.remote_ip,
              )
              # Log out and clear session data
              log_out
              redirect_to sign_app_root_path, notice: t("sign.app.configuration.withdrawal.create.success")
            end
          end
      end
    end
  end
end
