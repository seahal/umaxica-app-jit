# typed: false
# frozen_string_literal: true

module Docs
  module Com
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Session
      include ::Preference::Regional
      include ::Authentication::Viewer
      include ::Authorization::Viewer
      include ::Verification::Viewer
      include Pundit::Authorization
      include ::Oidc::SsoInitiator
      include ::CurrentSupport
      include ::Finisher

      before_action :check_default_rate_limit

      before_action :reset_flash

      allow_browser versions: :modern

      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      after_action :purge_current

      # FIXME: Resolve the URL issues before deploying.
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: %w(http://docs.com.localhost https://docs.com.localhost),
                           with: :exception

      public_strict!

      public

      def oidc_client_id
        "docs_com"
      end

      private
    end
  end
end
