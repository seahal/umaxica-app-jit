module Sign
  module App
    class WithdrawalsController < ApplicationController
      before_action :authenticate_user

      def new
        # NOTE: change this status check according to your business logic
        raise InvalidUserStatusError.new(invalid_status: "new is not implemented") unless @user.user_identity_status_id == "NONE"
      end

      def create
        # NOTE: change this status check according to your business logic
        raise InvalidUserStatusError.new(invalid_status: "new is not implemented") unless @user.user_identity_status_id == "NONE"

        # Soft delete: set withdrawn_at to now and mark pre-withdrawal status
        current_user.withdrawn_at = Time.current
        current_user.user_identity_status_id = UserIdentityStatus::PRE_WITHDRAWAL_CONDITION

        if current_user.save
          # Reset session only after successful DB update
          reset_session
          redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.create.success")
        else
          render :new, status: :unprocessable_content
        end
      end

      def update
        # Recovery: clear withdrawn_at if within the model-configured recovery window
        if current_user.can_recover?
          if current_user.update(withdrawn_at: nil)
            redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.update.recovered")
          else
            redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.update.failed")
          end
        else
          redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.update.cannot_recover")
        end
      end

      def destroy
        # Log intent and perform destroy inside a transaction. Prefer background job
        # for heavy deletions; here we attempt synchronous destroy with graceful handling.
        begin
          User.transaction do
            current_user.destroy!
            reset_session
            redirect_to sign_app_root_path, notice: t("sign.app.withdrawal.destroy.success")
          end
        rescue StandardError => e
          Rails.logger.error("User deletion failed: #{e.message}")
          redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.destroy.failed")
        end
      end

      private

      def authenticate_user
        # TODO: Implement proper authentication using session or JWT
        # Current mock implementation is for development only
        # DO NOT use User.first in production - implement proper session validation
        @user = current_user
        redirect_to sign_app_root_path, alert: t("sign.app.withdrawal.authenticate_error") unless @user
      end

      def current_user
        # TODO: Replace with actual session-based authentication
        # This is a placeholder implementation
        @current_user ||= begin
                            # Test environment: support X-TEST-CURRENT-USER header
                            test_user_id = request.headers["X-TEST-CURRENT-USER"]
                            if test_user_id.present?
                              User.find_by(id: test_user_id)
                            elsif session[:user_id].present?
                              User.find_by(id: session[:user_id])
                            end
                          end
      end
    end
  end
end
