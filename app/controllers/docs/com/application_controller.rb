# frozen_string_literal: true

module Docs
  module Com
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Regional

      protect_from_forgery with: :exception

      allow_browser versions: :modern
    end
  end
end
