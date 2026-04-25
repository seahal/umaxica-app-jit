# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module Org
        class ApplicationController < ::ApplicationController
          def self.local_prefixes
            prefixes = super.map { |p| p.delete_prefix('jit/identity/') }
            app_prefix = controller_path.sub("/org/", "/app/").delete_prefix('jit/identity/')
            prefixes.include?(app_prefix) ? prefixes : prefixes + [app_prefix]
          end

          layout "sign/org/application"
          include ::RateLimit # Rate limiting protection for requests
          include ::Session
          include ::Preference::Global

          activate_preference_global
          include ::Preference::Adoption
          include ::Authentication::Staff

          activate_staff_authentication
          include ::Authorization::Staff
          include ::Verification::Staff
          include ActionPolicy::Controller
          include ::RestrictedSessionGuard
          include ::CurrentSupport
          include ::Finisher

          allow_browser versions: :modern

          # Restricted session guard - explicitly enabled to block restricted sessions
          # from accessing routes other than /in/session
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
          before_action :enforce_restricted_session_guard!
          before_action :transparent_refresh_access_token, unless: -> { request.format.json? }
          before_action :enforce_access_policy!
          before_action :enforce_verification_if_required
          before_action :set_current
          before_action :set_current_observability
          after_action :purge_current
          after_action :_reset_current_state

          protect_from_forgery using: :header_or_legacy_token,
                               trusted_origins: ENV.fetch(
                                 "IDENTITY_SIGN_ORG_TRUSTED_ORIGINS",
                                 "http://sign.org.localhost,https://sign.org.localhost",
                               )
                                 .split(",").map(&:strip),
                               with: :exception

          guest_only!

          private

          # Redirect logged-in users from guest_only! pages to the configuration page.
          # Overrides Authentication::Base#main_app.after_login_path. ri is added automatically via default_url_options.
          def after_login_path
            identity.sign_org_configuration_path
          rescue StandardError
            "/"
          end
        end
      end
    end
  end
end
