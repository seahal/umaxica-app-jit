# typed: false
# frozen_string_literal: true

module Core
  module Org
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Authentication::Staff
      include ::Authorization::Staff
      include ::Verification::Staff
      include ::Preference::Regional
      include Pundit::Authorization
      include ::Oidc::SsoInitiator
      include ::Current
      include ::Finisher

      allow_browser versions: :modern

      before_action :set_preferences_cookie

      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      skip_before_action :set_preferences_cookie, raise: false
      skip_before_action :canonicalize_regional_params, raise: false
      skip_before_action :set_locale, raise: false
      skip_before_action :set_timezone, raise: false
      skip_before_action :set_color_theme, raise: false
      before_action :canonicalize_regional_params
      before_action :set_locale
      before_action :set_timezone
      before_action :set_color_theme
      before_action :set_current
      append_after_action :finish_request

      # FIXME: Resolve the URL issues before deploying.
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: %w(http://org.localhost https://org.localhost),
                           with: :exception

      public_strict!

      private

      def oidc_client_id
        "core_org"
      end

      def oidc_sign_host
        ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
      end
    end
  end
end
