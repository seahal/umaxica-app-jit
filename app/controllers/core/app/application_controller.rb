# typed: false
# frozen_string_literal: true

module Core
  module App
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Authentication::User
      include ::Authorization::User
      include ::Verification::User
      include ::Preference::Regional
      include Pundit::Authorization
      include ::Oidc::SsoInitiator
      include ::CurrentSupport
      include ::Finisher

      allow_browser versions: :modern

      # FIXME: Resolve the URL issues before deploying.
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: %w(http://app.localhost),
                           with: :exception

      # NOTE: Order matters (dependencies rely on this sequence)
      before_action :enforce_withdrawal_gate!
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? }
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      skip_before_action :set_preferences_cookie, raise: false
      skip_before_action :canonicalize_regional_params, raise: false
      skip_before_action :set_locale, raise: false
      skip_before_action :set_timezone, raise: false
      skip_before_action :set_color_theme, raise: false
      before_action :set_preferences_cookie
      before_action :canonicalize_regional_params
      before_action :set_locale
      before_action :set_timezone
      before_action :set_color_theme
      before_action :set_current
      append_after_action :finish_request

      # NOTE: Authentication is intentionally disabled in this domain.
      public_strict!

      private

      def oidc_client_id
        "core_app"
      end
    end
  end
end
