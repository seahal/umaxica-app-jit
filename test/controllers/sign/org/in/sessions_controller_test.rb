# frozen_string_literal: true

require "test_helper"

class Sign::Org::In::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "edit without gate redirects to login with alert" do
    get new_sign_org_in_secret_url(ri: "jp"),
        headers: browser_headers.merge("Host" => "sign.org.localhost")

    assert_response :success
  end

  test "update without gate redirects to login with alert" do
    post sign_org_in_secret_url(ri: "jp"),
         params: { revoke_session_ids: ["some-id"] },
         headers: browser_headers.merge("Host" => "sign.org.localhost")

    assert_response :no_content
  end

  test "edit for passkey session without gate redirects to login" do
    get new_sign_org_in_passkey_url(ri: "jp"),
        headers: browser_headers.merge("Host" => "sign.org.localhost")

    assert_response :success
  end

  test "update for passkey session without gate redirects to login" do
    post verification_sign_org_in_passkeys_url,
         params: { revoke_session_ids: ["some-id"] },
         headers: browser_headers.merge("Host" => "sign.org.localhost")

    assert_response :bad_request
  end
end
