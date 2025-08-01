# frozen_string_literal: true

module Auth
  module App
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      allow_browser versions: :modern

      protected

      def logged_in_user?
        # TODO: Implement user authentication logic
        false
      end
    end
  end
end
