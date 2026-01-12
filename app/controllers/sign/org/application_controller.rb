# frozen_string_literal: true

module Sign
  module Org
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::RateLimit
      include ::Preference::Global
      include ::Authentication::Staff
      include ::Authorization::Staff
      include ::Sign::ErrorResponses

      protect_from_forgery with: :exception

      allow_browser versions: :modern

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
