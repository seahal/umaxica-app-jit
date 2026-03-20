# typed: false
# frozen_string_literal: true

module News
  module Com
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Regional
      include ::Authentication::Viewer
      include ::Authorization::Viewer
      include ::Verification::Viewer
      include Pundit::Authorization
      include ::Oidc::SsoInitiator
      include ::Current
      include ::Finisher

      allow_browser versions: :modern

      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      append_after_action :finish_request

      # FIXME: Resolve the URL issues before deploying.
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: %w(http://news.com.localhost https://news.com.localhost),
                           with: :exception

      public_strict!

      private

      def oidc_client_id
        "news_com"
      end
    end
  end
end
