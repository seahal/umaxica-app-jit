# frozen_string_literal: true

module Core
  module Com
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::Authentication::User
      include ::AuthorizationAudit
      include ::Preference::Main
      include ::Regionalization
      include ::Preference::Regional

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      before_action :set_locale
      before_action :set_timezone

      # Note: AuthorizationAudit concern handles Pundit::NotAuthorizedError
      # and provides audit logging functionality
    end
  end
end
