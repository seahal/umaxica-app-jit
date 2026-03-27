# typed: false
# frozen_string_literal: true

module Core
  module Com
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Regional
      include ::Authentication::User
      include ::Authorization::User
      include ::Verification::User
      include Pundit::Authorization
      include ::Oidc::SsoInitiator
      include ::CurrentSupport
      include ::Finisher

      allow_browser versions: :modern

      # FIXME: Resolve the URL issues before deploying.
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: %w(http://com.localhost),
                           with: :exception

      # NOTE: Order matters (dependencies rely on this sequence)
      #       Layer order: RateLimit → Preference → AuthN(including AuthZ) → Verification → CurrentSupport
      before_action :check_default_rate_limit
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? }
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      before_action :enforce_withdrawal_gate!
      append_after_action :finish_request

      # NOTE: Authentication is intentionally disabled in this domain.
      public_strict!

      private

      def oidc_client_id
        "core_com"
      end
    end
  end
end
