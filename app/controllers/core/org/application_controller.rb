# typed: false
# frozen_string_literal: true

module Core
  module Org
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Session
      include ::Preference::Regional
      include ::Authentication::Staff
      include ::Authorization::Staff
      include ::Verification::Staff
      include Pundit::Authorization
      include ::Oidc::SsoInitiator
      include ::CurrentSupport
      include ::Finisher

      allow_browser versions: :modern

      # FIXME: Resolve the URL issues before deploying.
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: %w(http://org.localhost https://org.localhost),
                           with: :exception

      # NOTE: Order matters (dependencies rely on this sequence)
      # Layer order: RateLimit -> Preference -> AuthN(including AuthZ) -> Verification -> CurrentSupport
      before_action :check_default_rate_limit
      before_action :reset_flash
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? }
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      before_action :set_current_observability
      after_action :purge_current

      public_strict!

      public

      def oidc_client_id
        "core_org"
      end

      def oidc_sign_host
        ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
      end

      private
    end
  end
end
