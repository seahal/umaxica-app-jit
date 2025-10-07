# frozen_string_literal: true

module Apex
  module Org
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::RateLimit

      allow_browser versions: :modern

      before_action :set_locale
      before_action :set_timezone

      private

      def set_locale
        I18n.locale = session[:language]&.downcase || I18n.default_locale
      end

      def set_timezone
        Time.zone = session[:timezone] if session[:timezone].present?
      end
    end
  end
end
