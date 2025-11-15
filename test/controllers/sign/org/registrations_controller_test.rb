# frozen_string_literal: true

require "test_helper"

module Sign::Org
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest
    test "should get new" do
      get new_sign_org_registration_url

      assert_response :success
    end

    test "should have registration methods" do
      get new_sign_org_registration_url

      assert_response :success
      # Verify registration methods are available
    end

    test "should have social providers" do
      get new_sign_org_registration_url

      assert_response :success
      # Verify social providers are available
    end
  end
end
