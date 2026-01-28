# frozen_string_literal: true

module News
  module Com
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Auth::Base

      public_strict!
      include ::Preference::Regional

      protect_from_forgery with: :exception
      allow_browser versions: :modern
    end
  end
end
