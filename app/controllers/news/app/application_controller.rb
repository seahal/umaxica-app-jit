# frozen_string_literal: true

module News
  module App
    class ApplicationController < ActionController::Base
      include ::Fuse
      include ::Preference::Regional

      protect_from_forgery with: :exception
      include ::RateLimit
      include ::Auth::Base

      public_strict!

      allow_browser versions: :modern
    end
  end
end
