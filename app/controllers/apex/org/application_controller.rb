# typed: false
# frozen_string_literal: true

module Apex
  module Org
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Global
      include ::Preference::Adoption
      include ::Authentication::Staff
      include ::Authorization::Staff
      include ::Verification::Staff
      include Pundit::Authorization
      include ::Oidc::SsoInitiator
      include ::CurrentSupport
      include ::Finisher

      allow_browser versions: :modern

      # NOTE: Order matters (dependencies rely on this sequence)
      # Layer order: RateLimit -> Preference -> AuthN(including AuthZ) -> Verification -> CurrentSupport
      before_action :check_default_rate_limit
      prepend_before_action :set_preferences_cookie # TODO: delete this line
      prepend_before_action :resolve_param_context # TODO: delete this line
      prepend_before_action :set_region # TODO: delete this line
      prepend_before_action :set_locale # TODO: delete this line
      prepend_before_action :set_timezone # TODO: delete this line
      prepend_before_action :set_color_theme # TODO: delete this line
      before_action :enforce_access_policy!  # TODO: delete this line
      before_action :enforce_verification_if_required # TODO: delete this line
      before_action :set_current # TODO: delete this line
      before_action :set_current_observability
      after_action :purge_current

      # FIXME: Resolve the URL issues before deploying.
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: %w(http://org.localhost https://org.localhost),
                           with: :exception

      auth_required!

      private

      def oidc_client_id
        "apex_org"
      end

      def oidc_sign_host
        ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
      end
    end
  end
end
