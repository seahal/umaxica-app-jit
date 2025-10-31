# frozen_string_literal: true

module Help
  module App
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::DefaultUrlOptions

      allow_browser versions: :modern
    end
  end
end
