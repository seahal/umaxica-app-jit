# frozen_string_literal: true

require "test_helper"

class Sign::App::SignUpGuardTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
  end

  test "deletes prefixed and unprefixed auth cookies on guarded sign-up entry" do
    user = User.create!(status_id: "VERIFIED_WITH_SIGN_UP")

    cookies["access_token"] = "a"
    cookies["refresh_token"] = "b"
    cookies["__Secure-access_token"] = "c"
    cookies["__Secure-refresh_token"] = "d"
    cookies["__Host-access_token"] = "e"
    cookies["__Host-refresh_token"] = "f"

    get new_sign_app_up_email_url(ri: "jp"), headers: default_headers.merge({ "X-TEST-CURRENT-USER" => user.id })

    assert_response :conflict

    set_cookie = response.headers["Set-Cookie"].to_s
    %w[
      access_token=
      refresh_token=
      __Secure-access_token=
      __Secure-refresh_token=
      __Host-access_token=
      __Host-refresh_token=
    ].each do |cookie_prefix|
      assert_includes set_cookie, cookie_prefix
    end

    assert_includes set_cookie, "path=/"
  end

  private

    def default_headers
      { "Host" => host, "HTTPS" => "on" }
    end

    def host
      ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    end
end
