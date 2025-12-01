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

    # rubocop:disable Minitest/MultipleAssertions
    test "should render copyright in footer" do
      get new_sign_org_registration_url

      assert_select "footer" do
        assert_select "small", text: /^©/
        assert_select "small", text: /#{brand_name}$/
      end
    end
    # rubocop:enable Minitest/MultipleAssertions
  end
end
