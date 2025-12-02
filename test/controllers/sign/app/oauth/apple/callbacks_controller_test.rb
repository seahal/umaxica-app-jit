require "test_helper"

module Sign
  module App
    module OAuth
      class AppleControllerTest < ActionDispatch::IntegrationTest
        setup do
          @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
          OmniAuth.config.test_mode = true
        end

        teardown do
          OmniAuth.config.mock_auth[:apple] = nil
          OmniAuth.config.test_mode = false
          Rails.application.env_config["omniauth.auth"] = nil
        end

        test "should handle OAuth callback" do
          assert_difference -> { User.count }, 1 do
            mock_apple_auth_hash
            get sign_app_oauth_apple_callback_url, headers: { "Host" => @host }
          end

          assert_oauth_success("sign.app.registration.oauth.apple.callback.success")
        end

        test "should handle OAuth callback with origin" do
          assert_difference -> { User.count }, 1 do
            mock_apple_auth_hash(info: { email: "test@privaterelay.appleid.com" })

            get sign_app_oauth_apple_callback_url,
                headers: { "Host" => @host },
                env: { "omniauth.origin" => "/original-page" }
          end

          assert_oauth_success("sign.app.registration.oauth.apple.callback.success")
        end

        private

        def assert_oauth_success(i18n_key)
          assert_redirected_to sign_app_root_url(host: @host)
          assert_equal(
            [I18n.t(i18n_key), true],
            [flash[:notice], session[:user_id].present?]
          )
        end

        def mock_apple_auth_hash(overrides = {})
          base = {
            provider: "apple",
            uid: "001234.abcdef1234567890.1234",
            info: {
              email: "test@privaterelay.appleid.com",
              first_name: "Test",
              last_name: "User"
            },
            credentials: {
              token: "mock_apple_token",
              refresh_token: "mock_apple_refresh_token",
              expires_at: 2.hours.from_now.to_i
            }
          }

          auth_hash = base.deep_merge(overrides)
          OmniAuth.config.mock_auth[:apple] = OmniAuth::AuthHash.new(auth_hash)
          Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:apple]
        end
      end
    end
  end
end
