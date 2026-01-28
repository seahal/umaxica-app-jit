# frozen_string_literal: true

require "test_helper"

class Sign::Org::In::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "edit without gate redirects to login with alert" do
    get edit_sign_org_in_session_url, headers: { "Host" => "sign.org.localhost" }

    assert_redirected_to new_sign_org_in_url
    assert_equal I18n.t(
      "session_limit.gate_expired",
      default: "操作がタイムアウトしました。もう一度ログインしてください。",
    ), flash[:alert]
  end

  test "update without gate redirects to login with alert" do
    patch sign_org_in_session_url,
          params: { revoke_session_ids: [ "some-id" ] },
          headers: { "Host" => "sign.org.localhost" }

    assert_redirected_to new_sign_org_in_url
    assert_equal I18n.t(
      "session_limit.gate_expired",
      default: "操作がタイムアウトしました。もう一度ログインしてください。",
    ), flash[:alert]
  end
end
