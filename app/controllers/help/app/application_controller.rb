# typed: false
# frozen_string_literal: true

module Help
  module App
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Regional
      include ::Authentication::User
      include ::Authorization::User
      include ::Verification::User
      include Pundit::Authorization
      include ::Oidc::SsoInitiator
      include ::CurrentSupport
      include ::Finisher

      before_action :check_default_rate_limit

      allow_browser versions: :modern

      # NOTE: Order matters (dependencies rely on this sequence)
      # Layer order: RateLimit → Preference → AuthN(including AuthZ) → Verification → CurrentSupport
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
                           trusted_origins: %w(http://help.app.localhost https://help.app.localhost),
                           with: :exception

      # NOTE: Order matters - these must run before auth callbacks
      # Preference::Regional callbacks need to be re-ordered to run first
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

      public_strict!

      private

      def oidc_client_id
        "help_app"
      end
    end
  end
end
