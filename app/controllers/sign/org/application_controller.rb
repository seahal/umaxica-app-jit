# frozen_string_literal: true

module Sign
  module Org
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::RateLimit
      include ::Preference::Global
      include ::Auth::Staff
      include SessionLimitPendingGuard

      guest_only!
      include ::Sign::ErrorResponses

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      before_action :set_locale
      before_action :set_timezone
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? }

      private

        def pending_allowed_actions
          [
            "sign/org/in/sessions#edit",
            "sign/org/in/sessions#update",
            "sign/org/outs#edit",
            "sign/org/outs#destroy"
          ]
        end

        def pending_session_limit_redirect_path
          edit_sign_org_in_session_path
        end
    end
  end
end
