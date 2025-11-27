# frozen_string_literal: true

module Sign
  module Org
    class ApplicationController < ActionController::Base
      # include Pundit::Authorization
      include ::DefaultUrlOptions
      include ::RateLimit

      allow_browser versions: :modern

      helper_method :logged_in?, :logged_in_staff?, :logged_in_user?

      protected

      def logged_in_staff?
        # TODO: Implement staff authentication logic
        false
      end

      def logged_in_user?
        # TODO: Implement staff-side end-user sessions
        false
      end

      def logged_in?
        logged_in_staff? || logged_in_user?
      end
    end
  end
end
