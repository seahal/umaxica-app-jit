# frozen_string_literal: true

require "test_helper"

module Sign::Org::Registration
  class EmailsControllerTest < ActionDispatch::IntegrationTest
    test "should get new" do
      get new_sign_org_registration_email_url

      assert_response :success
    end

    test "should clear session on new" do
      get new_sign_org_registration_email_url

      assert_response :success
      assert_nil session[:user_email_registration]
    end

    test "should render bad request if logged in on edit" do
      get edit_sign_org_registration_email_url(id: "test")

      assert_response :bad_request
    end
  end
end
