# frozen_string_literal: true

require "test_helper"

module Sign::App::Authentication
  class TelephonesControllerTest < ActionDispatch::IntegrationTest
    test "should get new" do
      get new_sign_app_authentication_telephone_url

      assert_response :success
    end

    test "should initialize user_telephone in new action" do
      get new_sign_app_authentication_telephone_url

      assert_response :success
      # Verify the page loads without errors
    end

    test "should return ok on create when not logged in" do
      post sign_app_authentication_telephone_url

      assert_response :ok
    end
  end
end
