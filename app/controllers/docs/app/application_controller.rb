# typed: false
# frozen_string_literal: true

module Docs
  module App
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Regional
      include ::Authentication::User
      include ::Authorization::User
      include ::Verification::User
      include Pundit::Authorization
      include ::Oidc::SsoInitiator
      include ::CurrentSupport
      include ::Finisher

      allow_browser versions: :modern

      before_action :check_default_rate_limit
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? }
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      before_action :enforce_withdrawal_gate!
      after_action :purge_current

      # FIXME: Resolve the URL issues before deploying.
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: %w(http://docs.app.localhost https://docs.app.localhost),
                           with: :exception

      public_strict!

      public

      def oidc_client_id
        "docs_app"
      end

      private
    end
  end
end
