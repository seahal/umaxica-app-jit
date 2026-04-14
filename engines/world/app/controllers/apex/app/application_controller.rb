# typed: false
# frozen_string_literal: true

module Apex
  module App
    class ApplicationController < ActionController::Base
      include ::RateLimit # FIXME: remove and set here rate limit
      include ::Session

      include ::Preference::Global

      activate_preference_global

      include ::Preference::Adoption # FIXME: I hate this line.
      include ::Authentication::User

      activate_user_authentication
      include ::Authorization::User
      include ::Verification::User
      include ActionPolicy::Controller
      include ::Oidc::SsoInitiator # FIXME: I hate this line.
      include ::CurrentSupport
      include ::Finisher
      include ::CsrfTrustedOrigins # TODO: nanikore?

      allow_browser versions: :modern

      # CSRF
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: csrf_trusted_origins(
                             "APEX_APP_TRUSTED_ORIGINS",
                             "http://app.localhost,https://app.localhost",
                           ),
                           with: :exception

      rate_limit(
        to: RateLimit::DEFAULT_RATE_LIMIT,
        within: RateLimit::DEFAULT_RATE_WINDOW,
        by: -> { request.remote_ip },
        with: -> { handle_rate_limit_exceeded!("default_ip", RateLimit::DEFAULT_RATE_WINDOW.to_i) },
        store: rate_limit_store,
        name: "default_ip",
      )

      # RATE LIMIT
      # rate_limit to: 10_000, within: 1.minutes
      #            store: Rails.application.config.rate_limit_store,
      #            with: -> {
      #              render plain: "Too many requests", status: 429
      #            }

      public_strict!

      before_action :validate_flash_boundary
      prepend_before_action :set_preferences_cookie # FIXME: I hate this line.
      prepend_before_action :resolve_param_context # FIXME: I hate this line.
      prepend_before_action :set_region # FIXME: I hate this line.
      prepend_before_action :set_locale # FIXME: I hate this line.
      prepend_before_action :set_timezone # FIXME: I hate this line.
      prepend_before_action :set_color_theme # FIXME: I hate this line.
      before_action :enforce_withdrawal_gate! # FIXME: I hate this line.
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? } # FIXME: I hate this line.
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      before_action :set_current_observability
      after_action :purge_current
      after_action :_reset_current_state

      public

      def oidc_client_id
        "apex_app"
      end

      def oidc_sign_host
        ENV.fetch("SIGN_APP_URL", "sign.app.localhost")
      end

      private
    end
  end
end
