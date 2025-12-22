require "test_helper"

module Auth
  module Org
    module Token
      class RefreshesControllerTest < ActionDispatch::IntegrationTest
        setup do
          @staff = staffs(:one)
          @staff_token = StaffToken.create!(staff_id: @staff.id)
          @refresh_token = @staff_token.rotate_refresh_token!
        end

        # rubocop:disable Minitest/MultipleAssertions
        test "POST create with valid refresh token returns new access token" do
          post auth_org_token_refresh_url(host: ENV["AUTH_STAFF_URL"]),
               params: { refresh_token: @refresh_token },
               as: :json

          assert_response :ok
          json_response = response.parsed_body

          assert json_response["access_token"]
          assert_equal "Bearer", json_response["token_type"]
          assert_equal ::Authentication::Base::ACCESS_TOKEN_EXPIRY.to_i, json_response["expires_in"]
        end
        # rubocop:enable Minitest/MultipleAssertions

        test "POST create with invalid refresh token returns unauthorized" do
          post auth_org_token_refresh_url(host: ENV["AUTH_STAFF_URL"]),
               params: { refresh_token: "invalid-token-id" },
               as: :json

          assert_response :unauthorized
          json_response = response.parsed_body

          assert_equal I18n.t("auth.token_refresh.errors.invalid_refresh_token"), json_response["error"]
        end

        test "POST create without refresh token returns bad request" do
          post auth_org_token_refresh_url(host: ENV["AUTH_STAFF_URL"]),
               params: {},
               as: :json

          assert_response :bad_request
          json_response = response.parsed_body

          assert_equal I18n.t("auth.token_refresh.errors.missing_refresh_token"), json_response["error"]
        end

        test "POST create with withdrawn staff returns unauthorized and destroys token" do
          @staff.update!(withdrawn_at: Time.current)

          assert_difference("StaffToken.count", -1) do
            post auth_org_token_refresh_url(host: ENV["AUTH_STAFF_URL"]),
                 params: { refresh_token: @refresh_token },
                 as: :json
          end

          assert_response :unauthorized
          json_response = response.parsed_body

          assert_equal I18n.t("auth.token_refresh.errors.invalid_refresh_token"), json_response["error"]
        end

        test "POST create with non-existent staff destroys token" do
          # rubocop:disable Rails/SkipsModelValidations
          @staff_token.update_columns(staff_id: SecureRandom.uuid)
          # rubocop:enable Rails/SkipsModelValidations

          assert_difference("StaffToken.count", -1) do
            post auth_org_token_refresh_url(host: ENV["AUTH_STAFF_URL"]),
                 params: { refresh_token: @refresh_token },
                 as: :json
          end

          assert_response :unauthorized
        end
      end
    end
  end
end
