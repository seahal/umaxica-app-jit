# typed: false
# frozen_string_literal: true

module Core
  module App
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Session
      include ::Preference::Regional
      include ::Authentication::User
      include ::Authorization::User
      include ::Verification::User
      include Pundit::Authorization # TODO: i want to remove this inlucde
      include ::Oidc::SsoInitiator # TODO: should not set this line
      include ::CurrentSupport
      include ::Finisher

      allow_browser versions: :modern

      # FIXME: Resolve the URL issues before deploying.
      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: %w(http://app.localhost),
                           with: :exception

      # NOTE: Order matters (dependencies rely on this sequence)
      # Layer order: RateLimit -> Preference -> AuthN(including AuthZ) -> Verification -> CurrentSupport
      before_action :check_default_rate_limit
      before_action :reset_flash
      before_action :enforce_withdrawal_gate! # TODO: REMOVE THIS. what the hell why we set this here?
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? } # TODO: what is this?
      before_action :enforce_access_policy! # TODO: what is this line?
      before_action :enforce_verification_if_required # TODO: what is this line?
      before_action :set_current
      after_action :purge_current

      # FIXME: re-set
      public_strict!

      public

      def oidc_client_id
        "core_app"
      end

      private
    end
  end
end
