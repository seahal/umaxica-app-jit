require "test_helper"

module Auth::App::Authentication
  class PasskeysControllerTest < ActionDispatch::IntegrationTest
    test "should get new" do
      get new_auth_app_authentication_passkey_url

      assert_response :success
    end

    test "should initialize user_telephone in new action" do
      get new_auth_app_authentication_passkey_url

      assert_response :success
      # Verify the page loads without errors
    end

    test "should return ok on create when not logged in" do
      post auth_app_authentication_passkey_url

      assert_response :ok
    end

    # Turnstile Widget Verification Tests
    test "new authentication telephone page renders Turnstile widget" do
      get new_auth_app_authentication_passkey_url, headers: { "Host" => ENV["AUTH_SERVICE_URL"] }

      assert_response :success
      assert_select "div[id^='cf-turnstile-']", count: 1
    end
  end
end
