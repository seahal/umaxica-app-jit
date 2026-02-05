# frozen_string_literal: true

module Sign
  module Org
    class VerificationsController < ApplicationController
      auth_required!
      before_action :authenticate_staff!
      before_action :set_actor_token

      def show
        @reauth_sessions = ReauthSession.for_actor(@actor_token).recent_first.limit(50)
      end

      private

      def set_actor_token
        @actor_token = token_class.find_by!(public_id: current_session_public_id)
      end
    end
  end
end
