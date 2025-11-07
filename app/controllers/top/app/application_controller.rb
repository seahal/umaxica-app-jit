# frozen_string_literal: true

module Top
  module App
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::RateLimit
      include ::DefaultUrlOptions
      include ::Top::Concerns::Regionalization

      allow_browser versions: :modern

      before_action :set_locale
      before_action :set_timezone

      protected

      def logged_in_user?
        false
      end
    end
  end
end
