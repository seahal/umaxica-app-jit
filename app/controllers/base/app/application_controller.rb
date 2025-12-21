# frozen_string_literal: true

module Base
  module App
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      include ::Authentication::User
      include ::Authorization::User
      include ::AuthorizationAudit
      include ::RateLimit
      include ::DefaultUrlOptions
      include Base::Concerns::Regionalization

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      before_action :set_locale
      before_action :set_timezone

      # Note: AuthorizationAudit concern handles Pundit::NotAuthorizedError
      # and provides audit logging functionality
    end
  end
end
