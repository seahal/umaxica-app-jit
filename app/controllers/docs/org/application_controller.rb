# typed: false
# frozen_string_literal: true

module Docs
  module Org
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Regional
      include ::Authentication::Staff
      include ::Authorization::Staff
      include ::Verification::Staff
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
                           trusted_origins: %w(http://docs.org.localhost https://docs.org.localhost),
                           with: :exception

      public_strict!

      private

      def oidc_client_id
        "docs_org"
      end

      def oidc_sign_host
        ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
      end
    end
  end
end
