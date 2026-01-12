# frozen_string_literal: true

require "test_helper"

class Sign::Org::In::PasskeysControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_sign_org_in_passkey_url(ri: "jp")
    assert_response :success
  end

  test "should get create" do
    post sign_org_in_passkey_url(ri: "jp")
    assert_response :success
  end
end
