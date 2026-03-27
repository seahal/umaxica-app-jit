# typed: false
# frozen_string_literal: true

module News
  module Com
    class ApplicationController < ActionController::Base
      include ::RateLimit

      include ::Preference::Regional

      include ::Authentication::Viewer

      include ::Authorization::Viewer

      include ::Verification::Viewer

      include Pundit::Authorization

      include ::Oidc::SsoInitiator

      include ::CurrentSupport

      include ::Finisher

      before_action :check_default_rate_limit

      allow_browser versions: :modern

      # NOTE: Order matters - Preference callbacks run before auth
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
                           trusted_origins: %w(http://news.com.localhost https://news.com.localhost),
                           with: :exception

      public_strict!

      private

      def oidc_client_id
        "news_com"
      end
    end
  end
end
