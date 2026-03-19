# typed: false
# frozen_string_literal: true

module Help
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

      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      append_after_action :finish_request

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      public_strict!

      private

      def oidc_client_id
        "help_org"
      end

      def oidc_sign_host
        ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
      end
    end
  end
end
