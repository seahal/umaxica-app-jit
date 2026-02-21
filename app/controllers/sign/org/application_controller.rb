# frozen_string_literal: true

module Sign
  module Org
    class ApplicationController < ActionController::Base
      include ::Fuse
      include ::RateLimit
      include ::Authentication::Staff
      include ::Authorization::Staff
      include ::Verification::Staff
      include ::Preference::Global
      include Pundit::Authorization
      include ::Finisher

      protect_from_forgery with: :exception

      allow_browser versions: :modern

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
