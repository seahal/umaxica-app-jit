# typed: false
# frozen_string_literal: true

module Apex
  module Org
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Session
      include ::Preference::Global
      include ::Preference::Adoption  # FIXME: I hate this line.
      include ::Authentication::Staff
      include ::Authorization::Staff
      include ::Verification::Staff
      include Pundit::Authorization  # FIXME: I hate this line.
      include ::Oidc::SsoInitiator # FIXME: I hate this line.
      include ::CurrentSupport
      include ::Finisher

      allow_browser versions: :modern

      # NOTE: Order matters (dependencies rely on this sequence)
      # Layer order: RateLimit -> Preference -> AuthN(including AuthZ) -> Verification -> CurrentSupport
      before_action :check_default_rate_limit
      before_action :reset_flash
      prepend_before_action :set_preferences_cookie
      prepend_before_action :resolve_param_context
      prepend_before_action :set_region
      prepend_before_action :set_locale
      prepend_before_action :set_timezone
      prepend_before_action :set_color_theme
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      before_action :set_current_observability
      after_action :purge_current

      # FIXME: Resolve the URL issues before deploying.
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: %w(http://org.localhost https://org.localhost),
                           with: :exception

      auth_required!

      public

      def oidc_client_id
        "apex_org"
      end

      def oidc_sign_host
        ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
      end

      private
    end
  end
end
