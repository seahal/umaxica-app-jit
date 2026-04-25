# typed: false
# frozen_string_literal: true

module Post
  module Com
    class ApplicationController < ::ApplicationController
      def self.local_prefixes
        super.map { |p| p.delete_prefix('jit/distributor/') }
      end

      layout "post/com/application"
      include ::RateLimit
      include ::Session
      include ::Preference::Regional

      activate_preference_regional
      include ::Authentication::Viewer

      activate_viewer_authentication
      include ::Authorization::Viewer
      include ::Verification::Viewer
      include ActionPolicy::Controller
      include ::Oidc::SsoInitiator
      include ::CurrentSupport
      include ::Finisher
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

      allow_browser versions: :modern

      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      before_action :set_current_observability
      after_action :purge_current
      after_action :_reset_current_state

      protect_from_forgery using: :header_or_legacy_token,
                           trusted_origins: csrf_trusted_origins(
                             "DISTRIBUTOR_POST_COM_TRUSTED_ORIGINS",
                             "http://docs.com.localhost,https://docs.com.localhost",
                           ),
                           with: :exception

      public_strict!

      public

      def oidc_client_id
        "post_com"
      end

      private
    end
  end
end
