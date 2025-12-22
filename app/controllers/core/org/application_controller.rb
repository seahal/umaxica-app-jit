module Core
  module Org
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::Authentication::Staff
      include ::Authorization::Staff
      include ::AuthorizationAudit

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      # Note: AuthorizationAudit concern handles Pundit::NotAuthorizedError
      # and provides audit logging functionality
    end
  end
end
