# frozen_string_literal: true

require "cgi"

module Sign
  module App
    module Social
      # Controller for social auth entry points and account management
      #
      # Routes:
      #   POST   /social/start          -> #start (entry point with intent)
      #   DELETE /social/:provider/unlink -> #unlink (remove linked identity)
      #
      # The actual OmniAuth callbacks are handled by:
      #   Sign::App::Auth::OmniauthCallbacksController
      class SessionsController < Sign::App::ApplicationController
        include SocialAuthConcern
        include Sign::App::SignUpGuard

        REQUIRE_REAUTH_FOR_UNLINK = true

        SUPPORTED_PROVIDERS = %w[google_oauth2 apple].freeze

        # Public access for start (login intent doesn't require auth)
        # For link/reauth intents, auth is checked in prepare_social_auth_intent!
        public_strict! only: %i[start]
        auth_required! only: %i[unlink]
        prepend_before_action :enforce_logged_out_for_signup!, only: %i[start], if: -> { params[:intent].to_s == "signup" }

        # POST /social/start?provider=google_oauth2&intent=login
        # Entry point for social auth flow.
        # Prepares session with intent/state, then POSTs to OmniAuth.
        #
        # Params:
        #   - provider: "google_oauth2" or "apple"
        #   - intent: "login", "link", or "reauth" (default: "login")
        #
        # Flow:
        #   1. Validate provider
        #   2. Prepare intent in session (generates state)
        #   3. Render auto-submit form that POSTs to /auth/:provider
        def start
          provider = params[:provider]
          intent = params[:intent] || "login"

          unless SUPPORTED_PROVIDERS.include?(provider)
            return redirect_to new_sign_app_in_path,
                               alert: I18n.t("sign.app.social.sessions.invalid_provider")
          end

          preserve_redirect_parameter

          # Prepare session with intent and state
          state = prepare_social_auth_intent!(intent)

          # Redirect to OmniAuth with preserved state. A 307 redirect
          # keeps the original POST so OmniAuth still sees POST requests.
          redirect_to "/auth/#{provider}?state=#{CGI.escape(state)}",
                      status: :temporary_redirect
        rescue SocialAuth::BaseError => e
          handle_social_auth_error(e)
        end

        # DELETE /social/:provider/unlink
        # Removes a linked social identity from current user.
        #
        # Security:
        #   - Requires authenticated user
        #   - Optionally requires recent re-authentication (REQUIRE_REAUTH_FOR_UNLINK)
        #   - Cannot unlink last remaining identity
        def unlink
          require_recent_reauth! if REQUIRE_REAUTH_FOR_UNLINK

          provider = params[:provider]
          normalized_provider = SocialIdentifiable.normalize_provider(provider)

          ActiveRecord::Base.connected_to(role: :writing) do
            SocialAuthService.unlink(provider: provider, user: current_resource)
          end

          redirect_to sign_app_configuration_path,
                      notice: I18n.t(
                        "sign.app.social.sessions.unlink.success",
                        provider: normalized_provider.humanize,
                      )
        rescue SocialAuth::BaseError => e
          redirect_to sign_app_configuration_path, alert: e.message
        end
      end
    end
  end
end
