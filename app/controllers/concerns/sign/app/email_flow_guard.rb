# frozen_string_literal: true

module Sign
  module App
    module EmailFlowGuard
      extend ActiveSupport::Concern

      STATE_INIT = "init"
      STATE_EMAIL_CREATED = "email_created"
      STATE_EMAIL_VERIFIED = "email_verified"
      VALID_STATES = [ STATE_INIT, STATE_EMAIL_CREATED, STATE_EMAIL_VERIFIED ].freeze

      FLOW_REQUIREMENTS = {
        new: STATE_INIT,
        create: STATE_INIT,
        edit: STATE_EMAIL_CREATED,
        update: STATE_EMAIL_CREATED,
        show: STATE_EMAIL_VERIFIED,
        destroy: STATE_EMAIL_VERIFIED
      }.freeze

      FLOW_PROGRESSIONS = {
        create: STATE_EMAIL_CREATED,
        update: STATE_EMAIL_VERIFIED,
        destroy: STATE_INIT
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

          if action_name.to_sym == :update && current_state == STATE_EMAIL_VERIFIED
            render plain: t("sign.app.registration.email.update.already_verified"), status: :conflict
            return
          end

          redirect_flow_violation
        end

        def email_flow_state
          current_state = session[SESSION_KEY]
          current_state = current_state.to_s if current_state.present?
          current_state = STATE_INIT unless VALID_STATES.include?(current_state)
          session[SESSION_KEY] = current_state
        end

        def progress_email_flow!(action)
          next_state = FLOW_PROGRESSIONS[action.to_sym]
          session[SESSION_KEY] = next_state if next_state
        end

        def reset_email_flow!
          session[SESSION_KEY] = STATE_INIT
        end

        def redirect_flow_violation
          flash[:alert] = t("sign.app.registration.email.flow.invalid")
          redirect_to new_sign_app_up_email_path
        end
    end
  end
end
