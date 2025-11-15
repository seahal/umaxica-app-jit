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

    # TODO: Uncomment when logged_in_staff? and logged_in_user? methods are available
    # test "should render bad request if logged in on edit" do
    #   # This would require authentication setup
    #   get edit_sign_app_registration_telephone_url(id: "test")
    #
    #   # Should return bad request if not logged in but session is nil
    #   assert_response :bad_request
    # end
    #
    # test "should redirect if session expired on edit" do
    #   get edit_sign_app_registration_telephone_url(id: "test")
    #
    #   assert_redirected_to new_sign_app_registration_telephone_path
    # end
  end
end
