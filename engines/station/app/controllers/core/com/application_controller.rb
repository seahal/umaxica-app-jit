# typed: false
# frozen_string_literal: true

module Core
  module Com
    class ApplicationController < ActionController::Base
      include ::RateLimit # FIXME: remove and set here rate limit
      include ::Session
      include ::Preference::Regional

      activate_preference_regional
      include ::Authentication::User

      activate_user_authentication
      include ::Authorization::User
      include ::Verification::User
      include ActionPolicy::Controller
      include ::Oidc::SsoInitiator # FIXME: I hate this line.
      include ::CurrentSupport
      include ::Finisher

      allow_browser versions: :modern

      include ::CsrfTrustedOrigins

      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: csrf_trusted_origins(
                             "CORE_COM_TRUSTED_ORIGINS",
                             "http://com.localhost,https://com.localhost",
                           ),
                           with: :exception

      rate_limit(
        to: RateLimit::DEFAULT_RATE_LIMIT,
        within: RateLimit::DEFAULT_RATE_WINDOW,
        by: -> { request.remote_ip },
        with: -> { handle_rate_limit_exceeded!("default_ip", RateLimit::DEFAULT_RATE_WINDOW.to_i) },
        store: rate_limit_store,
        name: "default_ip",
      )
      before_action :validate_flash_boundary
      before_action :enforce_withdrawal_gate!
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? }
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      before_action :set_current_observability
      after_action :purge_current
      after_action :_reset_current_state

      # NOTE: Authentication is intentionally disabled in this domain.
      public_strict!

      public

      def oidc_client_id
        "core_com"
      end

      private
    end
  end
end
