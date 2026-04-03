# typed: false
# frozen_string_literal: true

module Core
  module Com
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Session
      include ::Preference::Regional

      activate_preference_regional
      include ::Authentication::User

      activate_user_authentication
      include ::Authorization::User
      include ::Verification::User
      include Pundit::Authorization # FIXME: I hate this line.
      include ::Oidc::SsoInitiator # FIXME: I hate this line.
      include ::CurrentSupport
      include ::Finisher

      allow_browser versions: :modern

      # FIXME: Resolve the URL issues before deploying.
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: %w(http://com.localhost),
                           with: :exception

      # NOTE: Order matters (dependencies rely on this sequence)
      #       Layer order: RateLimit -> Preference -> AuthN(including AuthZ) -> Verification -> CurrentSupport
      before_action :check_default_rate_limit
      before_action :validate_flash_boundary
      before_action :enforce_withdrawal_gate!
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? }
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      before_action :set_current_observability
      after_action :purge_current
      after_action :_reset_current_state

      # NOTE: Authentication is intentionally disabled in this domain.
      public_strict!

      public

      def oidc_client_id
        "core_com"
      end

      private
    end
  end
end
