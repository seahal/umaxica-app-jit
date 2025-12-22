require "test_helper"

module Auth
  module App
    module Token
      class RefreshesControllerTest < ActionDispatch::IntegrationTest
        setup do
          @user = users(:one)
          @user_token = UserToken.create!(user_id: @user.id)
          @refresh_token = @user_token.rotate_refresh_token!
        end

        # rubocop:disable Minitest/MultipleAssertions
        test "POST create with valid refresh token returns new access token" do
          post auth_app_token_refresh_url(host: ENV["AUTH_SERVICE_URL"]),
               params: { refresh_token: @refresh_token },
               as: :json

          assert_response :ok
          json_response = response.parsed_body

          assert json_response["access_token"]
          assert_equal "Bearer", json_response["token_type"]
          assert_equal ::Authentication::Base::ACCESS_TOKEN_EXPIRY.to_i, json_response["expires_in"]
        end
        # rubocop:enable Minitest/MultipleAssertions

        test "POST create with invalid (non-existent) refresh token returns unauthorized" do
          post auth_app_token_refresh_url(host: ENV["AUTH_SERVICE_URL"]),
               params: { refresh_token: "missing.public_id" },
               as: :json

          assert_response :unauthorized
          json_response = response.parsed_body

          assert_equal I18n.t("auth.token_refresh.errors.invalid_refresh_token"), json_response["error"]
        end

        test "POST create with malformed refresh token returns unauthorized" do
          post auth_app_token_refresh_url(host: ENV["AUTH_SERVICE_URL"]),
               params: { refresh_token: "invalid-token-format" },
               as: :json

          assert_response :unauthorized
          json_response = response.parsed_body

          assert_equal I18n.t("auth.token_refresh.errors.invalid_refresh_token"), json_response["error"]
        end

        test "POST create without refresh token returns bad request" do
          post auth_app_token_refresh_url(host: ENV["AUTH_SERVICE_URL"]),
               params: {},
               as: :json

          assert_response :bad_request
          json_response = response.parsed_body

          assert_equal I18n.t("auth.token_refresh.errors.missing_refresh_token"), json_response["error"]
        end

        test "POST create with withdrawn user returns unauthorized and destroys token" do
          @user.update!(withdrawn_at: Time.current)

          assert_difference("UserToken.count", -1) do
            post auth_app_token_refresh_url(host: ENV["AUTH_SERVICE_URL"]),
                 params: { refresh_token: @refresh_token },
                 as: :json
          end

          assert_response :unauthorized
          json_response = response.parsed_body

          assert_equal I18n.t("auth.token_refresh.errors.invalid_refresh_token"), json_response["error"]
        end

        test "POST create with non-existent user destroys token" do
          # rubocop:disable Rails/SkipsModelValidations
          @user_token.update_columns(user_id: SecureRandom.uuid)
          # rubocop:enable Rails/SkipsModelValidations

          assert_difference("UserToken.count", -1) do
            post auth_app_token_refresh_url(host: ENV["AUTH_SERVICE_URL"]),
                 params: { refresh_token: @refresh_token },
                 as: :json
          end

          assert_response :unauthorized
        end
      end
    end
  end
end
