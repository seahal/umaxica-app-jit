# frozen_string_literal: true

module News
  module App
    class ApplicationController < ActionController::Base
      include ::Preference::Main
      include ::Preference::Regional

      protect_from_forgery with: :exception
      include ::RateLimit

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      before_action :set_locale
      before_action :set_timezone
    end
  end
end
