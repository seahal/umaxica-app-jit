# typed: false
# frozen_string_literal: true

module Docs
  module Org
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Session
      include ::Preference::Regional

      activate_preference_regional
      include ::Authentication::Staff

      activate_staff_authentication
      include ::Authorization::Staff
      include ::Verification::Staff
      include Pundit::Authorization
      include ::Oidc::SsoInitiator
      include ::CurrentSupport
      include ::Finisher

      allow_browser versions: :modern

      before_action :check_default_rate_limit

      before_action :validate_flash_boundary
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      before_action :set_current_observability
      after_action :purge_current
      after_action :_reset_current_state

      # FIXME: Resolve the URL issues before deploying.
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: %w(http://docs.org.localhost https://docs.org.localhost),
                           with: :exception

      public_strict!

      public

      def oidc_client_id
        "docs_org"
      end

      def oidc_sign_host
        ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
      end

      private
    end
  end
end
