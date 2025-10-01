# frozen_string_literal: true

module Apex
  module App
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::RateLimit

      allow_browser versions: :modern

      protected

      def logged_in_user?
        false
      end
    end
  end
end
