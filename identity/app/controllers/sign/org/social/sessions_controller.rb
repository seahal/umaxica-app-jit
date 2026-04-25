# typed: false
# frozen_string_literal: true

module Sign
  module Org
    module Social
      # Controller for staff social auth entry point.
      #
      # Routes:
      #   GET /social/session/new?provider=google_org -> #new
      #
      # Only supports "login" intent -- staff sign-up via social is not allowed.
      class SessionsController < Sign::Org::ApplicationController
        include SocialAuthConcern

        activate_social_auth_concern

        SUPPORTED_PROVIDERS = %w(google_org).freeze

        public_strict! only: %i(new)

        # GET /social/session/new?provider=google_org
        # Prepares intent/state in session, then redirects to OmniAuth provider.
        def new
          provider = params[:provider]

          unless SUPPORTED_PROVIDERS.include?(provider)
            return redirect_to(
              identity.new_sign_org_in_path,
              alert: I18n.t("sign.org.social.sessions.invalid_provider"),
            )
          end

          state = prepare_social_auth_intent!("login", provider: provider)

          safe_redirect_to(
            omniauth_authorize_path(provider, state: state),
            fallback: identity.new_sign_org_in_path,
          )
        rescue SocialAuth::BaseError => e
          handle_social_auth_error(e)
        end

        private

        def social_auth_failure_redirect_path
          identity.new_sign_org_in_path
        end
      end
    end
  end
end
