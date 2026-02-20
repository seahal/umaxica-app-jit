# frozen_string_literal: true

module Core
  module Org
    class ApplicationController < ActionController::Base
      include ::Fuse
      include Pundit::Authorization
      include ::Auth::Staff
      include ::Preference::Regional
      include ::AuthorizationAudit

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      public_strict!

      # Note: AuthorizationAudit concern handles Pundit::NotAuthorizedError
      # and provides audit logging functionality
    end
  end
end
