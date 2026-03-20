# typed: false
# frozen_string_literal: true

module Sign
  module Org
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Authentication::Staff
      include ::Authorization::Staff
      include ::Verification::Staff
      include ::Preference::Global
      include ::Preference::Adoption
      include Pundit::Authorization
      include ::RestrictedSessionGuard
      include ::Current
      include ::Finisher

      allow_browser versions: :modern

      before_action :set_preferences_cookie

      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :resolve_param_context
      before_action :set_region
      before_action :set_locale
      before_action :set_timezone
      before_action :set_color_theme
      before_action :set_current
      append_after_action :finish_request

      # FIXME: Resolve the URL issues before deploying.
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: %w(http://sign.org.localhost https://sign.org.localhost),
                           with: :exception

      guest_only!

      private

      # Redirect logged-in users from guest_only! pages to the configuration page.
      # Overrides Auth::Base#after_login_path. ri is added automatically via default_url_options.
      def after_login_path
        sign_org_configuration_path
      rescue StandardError
        "/"
      end
    end
  end
end
