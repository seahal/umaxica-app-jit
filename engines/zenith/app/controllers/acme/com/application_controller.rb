# typed: false
# frozen_string_literal: true

module Jit
  module Zenith
    module Acme
      module Com
        class ApplicationController < ::ApplicationController
          def self.local_prefixes
            super.map { |p| p.sub(%r{\Ajit/zenith/}, "") }
          end

          layout "acme/com/application"
          include ::RateLimit # FIXME: remove and set here rate limit
          include ::Session
          include ::Preference::Global

          activate_preference_global
          include ::Authentication::Customer

          activate_customer_authentication
          include ::Authorization::Customer
          include ::Verification::Customer
          include ActionPolicy::Controller
          include ::Oidc::SsoInitiator
          include ::CurrentSupport
          include ::Finisher

          allow_browser versions: :modern

          include ::CsrfTrustedOrigins

          rate_limit(
            to: RateLimit::DEFAULT_RATE_LIMIT,
            within: RateLimit::DEFAULT_RATE_WINDOW,
            by: -> { request.remote_ip },
            with: -> { handle_rate_limit_exceeded!("default_ip", RateLimit::DEFAULT_RATE_WINDOW.to_i) },
            store: rate_limit_store,
            name: "default_ip",
          )
          before_action :validate_flash_boundary
          prepend_before_action :set_preferences_cookie
          prepend_before_action :resolve_param_context
          prepend_before_action :set_region
          prepend_before_action :set_locale
          prepend_before_action :set_timezone
          prepend_before_action :set_color_theme
          before_action :enforce_withdrawal_gate!
          before_action :transparent_refresh_access_token, unless: -> { request.format.json? }
          before_action :enforce_access_policy!
          before_action :enforce_verification_if_required
          before_action :set_current
          before_action :set_current_observability
          after_action :purge_current
          after_action :_reset_current_state

          protect_from_forgery using: :header_or_legacy_token,
                               trusted_origins: csrf_trusted_origins(
                                 "ZENITH_ACME_COM_TRUSTED_ORIGINS",
                                 "http://com.localhost,https://com.localhost",
                               ),
                               with: :exception

          public_strict!

          public

          def oidc_client_id
            "acme_com"
          end

          def oidc_sign_host
            ENV.fetch("IDENTITY_SIGN_APP_URL", "sign.app.localhost")
          end

          private
        end
      end
    end
  end
end
