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
                # Identity exists but no user? This is an edge case (maybe partial registration),
                # but for now we'll treat it as a new sign up flow or error.
                # Simulating auto-registration for now, or redirecting to registration.
                # TODO: Define specific flow for unlinked identity.
                # For this task, assuming we want to link or create user.

                # Creating a new user for the identity if one doesn't exist
                user = User.create!(user_identity_social_google: (identity if provider == "google_oauth2"),
                                    user_identity_social_apple: (identity if provider == "apple"))

                sign_in user
                redirect_to auth_app_root_path,
                            notice: notice_message
              end
            else
              # New identity
              # New identity
              # Create User first to satisfy null: false constraint on identity.user_id
              user = User.new

              # Associate identity with user
              identity.user = user
              if provider == "google_oauth2"
                user.user_identity_social_google = identity
              elsif provider == "apple"
                user.user_identity_social_apple = identity
              end

              if user.save
                # Confirm identity is saved (User save should save associated has_one if assigned)
                # If not, save identity explicitly
                identity.save! unless identity.persisted?

                sign_in user
                redirect_to auth_app_root_path,
                            notice: notice_message
              else
                redirect_to new_auth_app_authentication_path,
                            alert: "Failed to create user: #{user.errors.full_messages.to_sentence}"
              end
            end
          end
        rescue StandardError => e
          redirect_to new_auth_app_authentication_path, alert: "Authentication failed: #{e.message}"
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
