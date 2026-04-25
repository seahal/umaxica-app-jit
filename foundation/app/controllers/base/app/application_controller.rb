# typed: false
# frozen_string_literal: true

module Base
  module App
    class ApplicationController < ::ApplicationController
      def self.local_prefixes
        super.map { |p| p.delete_prefix('jit/foundation/') }
      end

      layout "base/app/application"
      include ::RateLimit # FIXME: remove and set here rate limit
      include ::Session
      include ::Preference::Regional

      activate_preference_regional
      include ::Authentication::User

      activate_user_authentication
      include ::Authorization::User
      include ::Verification::User
      include ActionPolicy::Controller
      include ::Oidc::SsoInitiator # TODO: should not set this line
      include ::CurrentSupport
      include ::Finisher

      allow_browser versions: :modern

      include ::CsrfTrustedOrigins

      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: csrf_trusted_origins(
                             "FOUNDATION_BASE_APP_TRUSTED_ORIGINS",
                             "http://app.localhost,https://app.localhost",
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
      before_action :enforce_withdrawal_gate! # TODO: REMOVE THIS. what the hell why we set this here?
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? } # TODO: what is this?
      before_action :enforce_access_policy! # TODO: what is this line?
      before_action :enforce_verification_if_required # TODO: what is this line?
      before_action :set_current
      before_action :set_current_observability
      after_action :purge_current
      after_action :_reset_current_state

      # FIXME: re-set
      public_strict!

      public

      def oidc_client_id
        "base_app"
      end

      private
    end
  end
end
