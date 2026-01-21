# frozen_string_literal: true

module Core
  module Com
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::AuthorizationAudit
      include ::RateLimit
      include ::Auth::User
      include ::Preference::Regional

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      public_strict!

      # Note: AuthorizationAudit concern handles Pundit::NotAuthorizedError
      # and provides audit logging functionality
    end
  end
end
