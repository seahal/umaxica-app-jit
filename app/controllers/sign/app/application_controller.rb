# typed: false
# frozen_string_literal: true

module Sign
  module App
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Authentication::User
      include ::Authorization::User
      include ::Verification::User
      include ::Preference::Global
      include ::Preference::Adoption
      include Pundit::Authorization
      include ::RestrictedSessionGuard # TODO: remove this.
      include ::CurrentSupport
      include ::Finisher

      allow_browser versions: :modern

      before_action :set_preferences_cookie

      before_action :enforce_withdrawal_gate!
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? }
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :resolve_param_context
      before_action :set_region
      before_action :set_locale
      before_action :set_timezone
      before_action :set_color_theme
      before_action :set_current
      append_after_action :finish_request

      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: ENV.fetch(
                             "SIGN_APP_TRUSTED_ORIGINS",
                             "http://sign.app.localhost,https://sign.app.localhost",
                           )
                             .split(",").map(&:strip),
                           with: :exception

      guest_only!

      private

      # Redirect logged-in users from guest_only! pages to the configuration page.
      # Overrides Auth::Base#after_login_path. ri is added automatically via default_url_options.
      def after_login_path
        sign_app_configuration_path
      rescue StandardError
        "/"
      end
    end
  end
end
