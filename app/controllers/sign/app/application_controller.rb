# typed: false
# frozen_string_literal: true

module Sign
  module App
    class ApplicationController < ActionController::Base
      include ::Fuse
      include ::RateLimit
      include ::Authentication::User
      include ::Authorization::User
      include ::Verification::User
      include ::Preference::Global
      include Pundit::Authorization
      include ::RestrictedSessionGuard
      include ::Finisher

      protect_from_forgery with: :exception

      allow_browser versions: :modern

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
