# typed: false
# frozen_string_literal: true

module Jit
  module Distributor
    module Post
      module Org
        class ApplicationController < ::ApplicationController
          def self.local_prefixes
            super.map { |p| p.sub(%r{\Ajit/distributor/}, "") }
          end

          layout "post/org/application"
          include ::RateLimit
          include ::Session
          include ::Preference::Regional

          activate_preference_regional
          include ::Authentication::Staff

          activate_staff_authentication
          include ::Authorization::Staff
          include ::Verification::Staff
          include ActionPolicy::Controller
          include ::Oidc::SsoInitiator
          include ::CurrentSupport
          include ::Finisher

          allow_browser versions: :modern

          include ::CsrfTrustedOrigins

          rate_limit(
            to: RateLimit::DEFAULT_RATE_LIMIT,
            within: RateLimit::DEFAULT_RATE_WINDOW,
            by: -> { request.remote_ip },
            with: -> { handle_rate_limit_exceeded!("default_ip", RateLimit::DEFAULT_RATE_WINDOW.to_i) },
            store: rate_limit_store,
            name: "default_ip",
          )
          before_action :validate_flash_boundary
          before_action :enforce_access_policy!
          before_action :enforce_verification_if_required
          before_action :set_current
          before_action :set_current_observability
          after_action :purge_current
          after_action :_reset_current_state

          protect_from_forgery using: :header_or_legacy_token,
                               trusted_origins: csrf_trusted_origins(
                                 "DISTRIBUTOR_POST_ORG_TRUSTED_ORIGINS",
                                 "http://docs.org.localhost,https://docs.org.localhost",
                               ),
                               with: :exception

          public_strict!

          public

          def oidc_client_id
            "post_org"
          end

          def oidc_sign_host
            ENV.fetch("IDENTITY_SIGN_ORG_URL", "sign.org.localhost")
          end

          private
        end
      end
    end
  end
end
