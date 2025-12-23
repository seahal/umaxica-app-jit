require "test_helper"

module Auth::App::Authentication
  class RecoveriesControllerTest < ActionDispatch::IntegrationTest
    test "should get new" do
      get new_auth_app_authentication_recovery_url

      assert_response :success
    end

    test "should render new on create" do
      post auth_app_authentication_recovery_url, params: {
        recovery_form: {
          account_identifiable_information: "user@example.com",
          recovery_code: "123456"
        }
      }

      assert_response :unprocessable_content
    end
  end
end
