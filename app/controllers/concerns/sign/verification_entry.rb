# typed: false
# frozen_string_literal: true

module Sign
  module VerificationEntry
    extend ActiveSupport::Concern

    def show
      return_to_param = params[:return_to].presence || params[:rd].presence

      if params[:scope].present? && return_to_param.present?
        start_reauth_session!(scope: params[:scope], return_to_param: return_to_param)
      end

      if current_reauth_session.present?
        return unless require_reauth_session!
      elsif verification_recent_for_get?(scope: @actor_token&.last_step_up_scope)
        flash.now[:notice] = I18n.t(verification_success_notice_key)
      end

      @available_methods = available_step_up_methods
    rescue ActionController::BadRequest
      session.delete(reauth_session_key)
      redirect_to verification_invalid_request_redirect_path(ri: params[:ri]),
                  alert: I18n.t("auth.step_up.invalid_request")
    end

    private

    def reauth_session_key
      self.class::REAUTH_SESSION_KEY
    end

    def verification_success_notice_key
      raise NotImplementedError, "#{self.class} must define #verification_success_notice_key"
    end

    def verification_invalid_request_redirect_path(ri:)
      raise NotImplementedError, "#{self.class} must define #verification_invalid_request_redirect_path"
    end
  end
end
