# frozen_string_literal: true

module News
  module Com
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Base
      include ::Preference::Locale

      protect_from_forgery with: :exception
      include ::DefaultUrlOptions

      protect_from_forgery with: :exception
      allow_browser versions: :modern
    end
  end
end
