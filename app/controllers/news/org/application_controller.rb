# typed: false
# frozen_string_literal: true

module News
  module Org
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Regional
      include ::Authentication::Staff
      include ::Authorization::Staff
      include ::Verification::Staff
      include Pundit::Authorization
      include ::Oidc::SsoInitiator
      include ::CurrentSupport
      include ::Finisher

      allow_browser versions: :modern

      # NOTE: Order matters - Preference callbacks run before auth
      before_action :check_default_rate_limit
      skip_before_action :set_preferences_cookie, raise: false
      skip_before_action :canonicalize_regional_params, raise: false
      skip_before_action :set_locale, raise: false
      skip_before_action :set_timezone, raise: false
      skip_before_action :set_color_theme, raise: false
      prepend_before_action :set_preferences_cookie
      prepend_before_action :canonicalize_regional_params
      prepend_before_action :set_locale
      prepend_before_action :set_timezone
      prepend_before_action :set_color_theme
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      after_action :purge_current

      # FIXME: Resolve the URL issues before deploying.
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: %w(http://news.org.localhost https://news.org.localhost),
                           with: :exception

      public_strict!

      private

      def oidc_client_id
        "news_org"
      end

      def oidc_sign_host
        ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
      end
    end
  end
end
