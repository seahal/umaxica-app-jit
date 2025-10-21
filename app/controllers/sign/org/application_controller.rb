# frozen_string_literal: true

module Sign
  module Org
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::DefaultUrlOptions
      include ::RateLimit

      allow_browser versions: :modern

      protected

      def logged_in_staff?
        # TODO: Implement staff authentication logic
        false
      end
    end
  end
end
