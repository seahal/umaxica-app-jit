# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class SessionsController < ApplicationController
        before_action :authenticate_user!
        before_action :set_session, only: %i(destroy)

        def index
          @sessions = current_user.user_tokens.where(revoked_at: nil).order(created_at: :desc)
        end

        def destroy
          if @session.public_id == current_session_public_id
            return render_current_session_error
          end

          @session.revoke!

          respond_to do |format|
            format.html do
              redirect_to(
                sign_app_configuration_sessions_path,
                status: :see_other,
                notice: t("sign.app.configuration.sessions.revoke.success"),
              )
            end
            format.json do
              head :see_other
            end
          end
        end

        private

        def render_current_session_error
          respond_to do |format|
            format.html do
              redirect_to(
                sign_app_configuration_sessions_path,
                alert: t("sign.app.configuration.sessions.revoke.failure"),
              )
            end
            format.json do
              render json: {
                error: t("sign.app.configuration.sessions.revoke.failure"),
              }, status: :unprocessable_content
            end
          end
        end

        def set_session
          @session = current_user.user_tokens.find_by(public_id: params[:id])
          return if @session

          head :not_found
          nil
        end
      end
    end
  end
end
