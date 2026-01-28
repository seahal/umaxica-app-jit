# frozen_string_literal: true

require "test_helper"

class Sign::Org::In::PasskeysControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_sign_org_in_passkey_url(ri: "jp")
    assert_response :success
  end

  test "should post options" do
    post options_sign_org_in_passkeys_url(ri: "jp"), params: { identifier: "invalid" }
    assert_response :unprocessable_content
  end
end
