require "test_helper"

module Sign
  module App
    module OAuth
      class GoogleOauth2ControllerTest < ActionDispatch::IntegrationTest
        self.use_transactional_tests = false

        setup do
          @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
          OmniAuth.config.test_mode = true
        end

        teardown do
          OmniAuth.config.mock_auth[:google_oauth2] = nil
          OmniAuth.config.test_mode = false
          Rails.application.env_config["omniauth.auth"] = nil

          # Clean up test data since we're not using transactional tests
          IdentitiesRecord.connected_to(role: :writing) do
            UserIdentityGoogleAuth.destroy_all
            UserIdentityEmail.destroy_all
            UserIdentitySecret.destroy_all
          end
          TokensRecord.connected_to(role: :writing) do
            UserToken.destroy_all
          end
          User.destroy_all
        end

        test "should handle OAuth callback" do
          assert_difference -> { User.count }, 1 do
            mock_google_auth_hash
            get sign_app_oauth_google_oauth2_callback_url, headers: { "Host" => @host }
          end

          assert_oauth_success("sign.app.registration.oauth.google.callback.success")
        end

        test "should handle OAuth callback with origin" do
          assert_difference -> { User.count }, 1 do
            mock_google_auth_hash(info: { email: "test@example.com" })

            get sign_app_oauth_google_oauth2_callback_url,
                headers: { "Host" => @host },
                env: { "omniauth.origin" => "/original-page" }
          end

          assert_oauth_success("sign.app.registration.oauth.google.callback.success")
        end

        private

        def assert_oauth_success(i18n_key)
          assert_redirected_to sign_app_root_url(host: @host)
          assert_equal I18n.t(i18n_key), flash[:notice]
          assert_not_nil cookies[:access_user_token], "Access token cookie should be set for JWT authentication"

          # Verify user was created
          user = User.last

          assert_not_nil user, "User should be created after OAuth callback"
        end

        def mock_google_auth_hash(overrides = {})
          base = {
            provider: "google_oauth2",
            uid: SecureRandom.uuid,
            info: {
              email: "test@example.com",
              name: "Test User",
              first_name: "Test",
              last_name: "User"
            },
            credentials: {
              token: "mock_token",
              refresh_token: "mock_refresh_token",
              expires_at: 1.hour.from_now.to_i
            },
            extra: {
              raw_info: { hd: "example.com" }
            }
          }

          auth_hash = base.deep_merge(overrides)
          OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(auth_hash)
          Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
        end
      end
    end
  end
end
