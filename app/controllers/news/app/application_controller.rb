# typed: false
# frozen_string_literal: true

module News
  module App
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Session
      include ::Preference::Regional
      include ::Authentication::User
      include ::Authorization::User
      include ::Verification::User
      include Pundit::Authorization
      include ::Oidc::SsoInitiator
      include ::CurrentSupport
      include ::Finisher

      allow_browser versions: :modern

      # NOTE: Order matters - Preference callbacks run before auth
      before_action :check_default_rate_limit
      before_action :reset_flash
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
      before_action :enforce_withdrawal_gate!
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? }
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      after_action :purge_current

      # FIXME: Resolve the URL issues before deploying.
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: %w(http://news.app.localhost https://news.app.localhost),
                           with: :exception

      public_strict!

      public

      def oidc_client_id
        "news_app"
      end

      private
    end
  end
end
