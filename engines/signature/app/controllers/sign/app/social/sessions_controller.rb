# typed: false
# frozen_string_literal: true

module Sign
  module App
    module Social
      # Controller for social auth entry points and account management
      #
      # Routes:
      #   GET    /social/session/new     -> #new (entry point with intent)
      #   DELETE /social/:provider/unlink -> #unlink (remove linked identity)
      #
      # The actual OmniAuth callbacks are handled by:
      #   Sign::App::Auth::OmniauthCallbacksController
      class SessionsController < Sign::App::ApplicationController
        include ::Verification::User
        include SocialAuthConcern

        activate_social_auth_concern

        SUPPORTED_PROVIDERS = %w(google_app apple).freeze

        # Public access for start (login intent doesn't require auth)
        # For link/reauth intents, auth is checked in prepare_social_auth_intent!
        public_strict! only: %i(new)
        auth_required! only: %i(unlink)
        before_action -> { require_step_up!(scope: "social_unlink") }, only: :unlink

        # GET /social/session/new?provider=google_app&intent=login
        # Entry point for social auth flow.
        # Prepares session with intent/state, then redirects to OmniAuth.
        #
        # Params:
        #   - provider: "google_app" or "apple"
        #   - intent: "login", "link", or "reauth" (default: "login")
        #
        # Flow:
        #   1. Validate provider
        #   2. Prepare intent in session (generates state)
        #   3. Redirect to /auth/:provider?state=...
        def new
          provider = params[:provider]
          intent = params[:intent] || "login"

          unless SUPPORTED_PROVIDERS.include?(provider)
            return redirect_to(
              new_sign_app_in_path,
              alert: I18n.t("sign.app.social.sessions.invalid_provider"),
            )
          end

          # Prepare session with intent context (OmniAuth manages OAuth state)
          state = prepare_social_auth_intent!(intent, provider: provider)

          safe_redirect_to(
            omniauth_authorize_path(provider, state: state),
            fallback: new_sign_app_in_path,
          )
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
          provider = params[:provider]
          normalized_provider = SocialIdentifiable.normalize_provider(provider)

          ActiveRecord::Base.connected_to(role: :writing) do
            SocialAuthService.unlink(provider: provider, user: current_resource)
          end

          audit_social_unlinked!(normalized_provider)

          redirect_to(
            sign_app_configuration_path,
            notice: I18n.t(
              "sign.app.social.sessions.unlink.success",
              provider: normalized_provider.humanize,
            ),
          )
        rescue SocialAuth::BaseError => e
          redirect_to(sign_app_configuration_path, alert: e.message)
        end

        private

        def audit_social_unlinked!(provider)
          ActivityRecord.connected_to(role: :writing) do
            UserActivityEvent.find_or_create_by!(id: UserActivityEvent::SOCIAL_UNLINKED)
            UserActivityLevel.find_or_create_by!(id: UserActivityLevel::NOTHING)
          end

          UserActivity.create!(
            actor_type: "User",
            actor_id: current_resource.id,
            event_id: UserActivityEvent::SOCIAL_UNLINKED,
            subject_id: current_resource.id.to_s,
            subject_type: "User",
            context: { provider: provider },
            ip_address: request.remote_ip,
            occurred_at: Time.current,
          )
        rescue ActiveRecord::RecordInvalid => e
          Rails.event.error(
            "sign.social.unlink.audit_failed",
            user_id: current_resource.id,
            provider: provider,
            errors: e.record.errors.full_messages,
          )
        end
      end
    end
  end
end
