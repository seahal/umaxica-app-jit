# frozen_string_literal: true

module Sign
  module App
    module Configuration
      class SessionsController < ApplicationController
        before_action :authenticate_user!
        before_action :set_session, only: %i(destroy)

        def index
          render json: { sessions: current_user.user_tokens.where(revoked_at: nil) }
        end

        def destroy
          if @session.public_id == current_session_public_id
            render json: { error: "Cannot revoke current session" }, status: :unprocessable_content
            return
          end

          @session.revoke!
          head :see_other
        end

        private

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
