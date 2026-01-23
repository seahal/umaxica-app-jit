# frozen_string_literal: true

module Sign
  module App
    module EmailFlowGuard
      extend ActiveSupport::Concern

      FLOW_REQUIREMENTS = {
        new: :init,
        create: :init,
        edit: :email_created,
        update: :email_created,
        show: :email_verified,
        destroy: :email_verified,
      }.freeze

      FLOW_PROGRESSIONS = {
        create: :email_created,
        update: :email_verified,
        destroy: :init,
      }.freeze

      SESSION_KEY = :sign_up_email_flow_state

      included do
        before_action :enforce_email_flow!, only: FLOW_REQUIREMENTS.keys
      end

      private

      def enforce_email_flow!
        required_state = FLOW_REQUIREMENTS[action_name.to_sym]
        return unless required_state

        current_state = email_flow_state
        return if current_state == required_state

        redirect_flow_violation
      end

      def email_flow_state
        session[SESSION_KEY] ||= :init
      end

      def progress_email_flow!(action)
        next_state = FLOW_PROGRESSIONS[action.to_sym]
        session[SESSION_KEY] = next_state if next_state
      end

      def reset_email_flow!
        session[SESSION_KEY] = :init
      end

      def redirect_flow_violation
        flash[:alert] = t("sign.app.registration.email.flow.invalid")
        redirect_to new_sign_app_up_email_path
      end
    end
  end
end
