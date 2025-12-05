# frozen_string_literal: true

require "test_helper"

module Sign::App::Registration
  class TelephonesControllerTest < ActionDispatch::IntegrationTest
    test "should get new" do
      get new_sign_app_registration_telephone_url

      assert_response :success
    end

    test "should clear session on new" do
      get new_sign_app_registration_telephone_url

      assert_response :success
      assert_nil session[:user_telephone_registration]
    end
  end
end
