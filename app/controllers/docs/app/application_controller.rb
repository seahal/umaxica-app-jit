# frozen_string_literal: true

module Docs
  module App
    class ApplicationController < ActionController::Base
      include ::Preference::Regional
      include ::RateLimit

      protect_from_forgery with: :exception

      allow_browser versions: :modern
    end
  end
end
