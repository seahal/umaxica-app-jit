# frozen_string_literal: true

module Sign
  module App
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Base
      include ::DefaultUrlOptions
      include ::Authentication::User
      include ::Authorization::User
      include Pundit::Authorization
      include Sign::ErrorResponses
      include ::Preference::Global

      protect_from_forgery with: :exception

      allow_browser versions: :modern
    end
  end
end
