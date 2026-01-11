# frozen_string_literal: true

module Sign
  module Org
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::RateLimit
      include ::Preference::Main
      include ::Authentication::Staff
      include ::Authorization::Staff
      include ::Sign::ErrorResponses
      include ::Preference::Global

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      before_action :set_locale
      before_action :set_timezone

      helper_method :logged_in?, :logged_in_staff?, :logged_in_user?

      protected

      def logged_in_staff?
        current_staff.present?
      end

      def logged_in_user?
        # TODO: Implement staff-side end-user sessions
        false
      end

      def logged_in?
        logged_in_staff?
      end
    end
  end
end
