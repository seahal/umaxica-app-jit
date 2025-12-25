module Auth
  module App
    module Social
      class SessionsController < Auth::App::ApplicationController
        def create
          ActiveRecord::Base.connected_to(role: :writing) do
            auth = request.env["omniauth.auth"] || mock_auth_from_test_mode
            raise "Missing OmniAuth data" unless auth

            provider = auth.provider

            identity = case provider
            when "google_oauth2"
              UserIdentitySocialGoogle.find_or_create_from_auth_hash(auth)
            when "apple"
              UserIdentitySocialApple.find_or_create_from_auth_hash(auth)
            else
              raise "Unknown provider: #{provider}"
            end

            notice_message = I18n.t("sign.app.social.sessions.create.success", provider: provider.humanize)

            if identity.persisted?
              # Existing identity, sign in if linked to a user
              if identity.user
                sign_in identity.user
                redirect_to auth_app_root_path,
                            notice: notice_message
              else
                # Identity exists but no user - create and link
                Rails.event.notify("auth.social.orphaned_identity",
                                   provider: provider,
                                   identity_id: identity.id)

                user = User.new
                identity.user = user
                if provider == "google_oauth2"
                  user.user_identity_social_google = identity
                elsif provider == "apple"
                  user.user_identity_social_apple = identity
                end

                user.save!
                sign_in user
                redirect_to auth_app_root_path,
                            notice: notice_message
              end
            else
              # New identity - create user and link
              user = User.new
              identity.user = user
              if provider == "google_oauth2"
                user.user_identity_social_google = identity
              elsif provider == "apple"
                user.user_identity_social_apple = identity
              end

              user.save!
              identity.save! unless identity.persisted?

              sign_in user
              redirect_to auth_app_root_path,
                          notice: notice_message
            end
          end
        rescue StandardError => e
          Rails.event.notify("auth.social.failed",
                             error_class: e.class.name,
                             error_message: e.message,
                             provider: auth&.provider)

          redirect_to new_auth_app_authentication_path,
                      alert: I18n.t("sign.app.social.sessions.create.failure")
        end

        private

          def sign_in(user)
            log_in(user)
          end

          def mock_auth_from_test_mode
            return unless Rails.env.test?

            provider = params[:provider]
            return unless provider

            OmniAuth.config.mock_auth[provider.to_sym] || OmniAuth.config.mock_auth[provider.to_s]
          end
      end
    end
  end
end
