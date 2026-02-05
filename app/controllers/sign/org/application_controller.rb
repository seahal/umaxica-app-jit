# frozen_string_literal: true

module Sign
  module Org
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::RateLimit
      include ::Preference::Global
      include ::Auth::Staff

      guest_only!
      include ::Sign::ErrorResponses

      protect_from_forgery with: :exception

      rescue_from ActionController::InvalidCrossOriginRequest, with: :handle_csrf_failure

      allow_browser versions: :modern

      before_action :set_locale
      before_action :set_timezone
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? }

      private

      def handle_csrf_failure
        if request.format.json?
          render json: { error: I18n.t("errors.invalid_authenticity_token", default: "セッションが期限切れです。ページを再読み込みしてください。") },
                 status: :unprocessable_content
        else
          raise ActionController::InvalidCrossOriginRequest
        end
      end
    end
  end
end
