require "test_helper"

module Sign
  module App
    module OAuth
      class GoogleOauth2ControllerTest < ActionDispatch::IntegrationTest
        setup do
          @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
          OmniAuth.config.test_mode = true
        end

        teardown do
          OmniAuth.config.mock_auth[:google_oauth2] = nil
          OmniAuth.config.test_mode = false
          Rails.application.env_config["omniauth.auth"] = nil
        end

        test "should handle OAuth callback" do
          assert_difference -> { User.count }, 1 do
            mock_google_auth_hash
            get sign_app_oauth_google_oauth2_callback_url, headers: { "Host" => @host }
          end

          assert_redirected_to sign_app_root_url(host: @host)
          assert_equal I18n.t("sign.app.registration.oauth.google.callback.success"), flash[:notice]
          assert_not_nil session[:user_id]
        end

        test "should handle OAuth callback with origin" do
          assert_difference -> { User.count }, 1 do
            mock_google_auth_hash(info: { email: "test@example.com" })

            get sign_app_oauth_google_oauth2_callback_url,
                headers: { "Host" => @host },
                env: { "omniauth.origin" => "/original-page" }
          end

          assert_redirected_to sign_app_root_url(host: @host)
          assert_equal I18n.t("sign.app.registration.oauth.google.callback.success"), flash[:notice]
        end

        private

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
