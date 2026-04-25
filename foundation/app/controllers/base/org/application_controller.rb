# typed: false
# frozen_string_literal: true

module Base
  module Org
    class ApplicationController < ::ApplicationController
      def self.local_prefixes
        super.map { |p| p.delete_prefix('jit/foundation/') }
      end

      layout "base/org/application"
      include ::RateLimit
      include ::Session
      include ::Preference::Regional

      activate_preference_regional
      include ::Authentication::Staff

      activate_staff_authentication
      include ::Authorization::Staff
      include ::Verification::Staff
      include ActionPolicy::Controller
      include ::Oidc::SsoInitiator
      include ::CurrentSupport
      include ::Finisher

      include ::CsrfTrustedOrigins

      allow_browser versions: :modern

      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: csrf_trusted_origins(
                             "FOUNDATION_BASE_ORG_TRUSTED_ORIGINS",
                             "http://org.localhost,https://org.localhost",
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
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? }
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      before_action :set_current_observability
      after_action :purge_current
      after_action :_reset_current_state

      public_strict!

      public

      def oidc_client_id
        "base_org"
      end

      def oidc_sign_host
        ENV.fetch("IDENTITY_SIGN_ORG_URL", "sign.org.localhost")
      end

      private
    end
  end
end
