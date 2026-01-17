# frozen_string_literal: true

module Sign
  module App
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Global
      include ::Auth::User
      include Pundit::Authorization
      include Sign::ErrorResponses

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      before_action :set_locale
      before_action :set_timezone
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? }

      private

      def transparent_refresh_access_token
        return if logged_in?

        refresh_plain = cookies[::Auth::Base::REFRESH_COOKIE_KEY]
        return if refresh_plain.blank?

        refreshed = refresh_access_token(refresh_plain)
        return unless refreshed

        remove_instance_variable(:@current_resource) if defined?(@current_resource)
      end
    end
  end
end
