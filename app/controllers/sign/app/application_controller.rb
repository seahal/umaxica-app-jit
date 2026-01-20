# frozen_string_literal: true

module Sign
  module App
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Global
      include ::Auth::User

      guest_only!
      include Pundit::Authorization
      include Sign::ErrorResponses

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      before_action :set_locale
      before_action :set_timezone
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? }
    end
  end
end
