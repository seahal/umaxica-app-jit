# frozen_string_literal: true

module Back
  module Com
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::Authentication::User
      include ::AuthorizationAudit

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      # Note: AuthorizationAudit concern handles Pundit::NotAuthorizedError
      # and provides audit logging functionality
    end
  end
end
