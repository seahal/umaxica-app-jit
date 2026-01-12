# frozen_string_literal: true

module Core
  module App
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::AuthorizationAudit
      include ::RateLimit
      include ::Authentication::User
      include ::Authorization::User
      include ::Preference::Regional

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      # Note: AuthorizationAudit concern handles Pundit::NotAuthorizedError
      # and provides audit logging functionality
    end
  end
end
