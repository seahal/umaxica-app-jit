# frozen_string_literal: true

require "test_helper"

class Sign::Org::In::SecretsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_sign_org_in_secret_url
    assert_response :success
  end

  test "should get create" do
    post sign_org_in_secret_url
    assert_response :success
  end
end
