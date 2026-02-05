# frozen_string_literal: true

require "test_helper"

class Sign::App::In::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "edit without gate redirects to login with alert" do
    get edit_sign_app_in_email_url(ri: "jp"),
        headers: browser_headers.merge("Host" => ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost"))

    assert_redirected_to new_sign_app_in_email_url(ri: "jp")
  end

  test "update without gate redirects to login with alert" do
    patch sign_app_in_email_url(ri: "jp"),
          params: { revoke_session_ids: ["some-id"] },
          headers: browser_headers.merge("Host" => ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost"))

    assert_redirected_to new_sign_app_in_email_url(ri: "jp")
  end

  test "edit for secret session without gate redirects to login" do
    get new_sign_app_in_secret_url(ri: "jp"),
        headers: browser_headers.merge("Host" => ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost"))

    assert_response :success
  end

  test "update for secret session without gate redirects to login" do
    post sign_app_in_secret_url(ri: "jp"),
         params: { revoke_session_ids: ["some-id"] },
         headers: browser_headers.merge("Host" => ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost"))

    assert_response :unprocessable_content
  end
end
