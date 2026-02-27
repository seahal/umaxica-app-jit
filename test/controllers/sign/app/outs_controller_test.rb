# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::App::OutsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end

  test "should get edit raises error without session" do
    get edit_sign_app_out_url(ri: "jp"), headers: { "Host" => @host }

    rt = Base64.urlsafe_encode64(edit_sign_app_out_url(ri: "jp", host: @host))

    assert_redirected_to new_sign_app_in_url(rt: rt, host: @host)
  end

  test "should destroy raises error without session" do
    delete sign_app_out_url(ri: "jp"), headers: { "Host" => @host }

    rt = Base64.urlsafe_encode64(sign_app_out_url(ri: "jp", host: @host))

    assert_redirected_to new_sign_app_in_url(rt: rt, host: @host)
  end

  test "should destroy with user session" do
    delete sign_app_out_url(ri: "jp"), headers: { "Host" => @host, "X-TEST-CURRENT-USER" => @user.id }

    assert_redirected_to sign_app_root_path(ri: "jp")
  end

  test "logout revokes refresh token, clears cookies, and blocks refresh reuse" do
    token_record = UserToken.create!(user: @user)
    refresh_plain = token_record.rotate_refresh_token!

    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain
    cookies[Auth::Base::ACCESS_COOKIE_KEY] = "access-dummy"
    delete sign_app_out_url(ri: "jp"), headers: {
      "Host" => @host,
      "X-TEST-CURRENT-USER" => @user.id,
    }

    assert_redirected_to sign_app_root_path(ri: "jp")
    assert UserToken.exists?(token_record.id)
    token_record.reload

    assert_predicate token_record.revoked_at, :present?

    raw_header = response.headers["Set-Cookie"] || response.headers["set-cookie"] || ""
    cookie_lines = Array(raw_header).flat_map { |line| line.to_s.split("\n") }.reject(&:empty?)

    access_cookie_line = cookie_lines.find { |line| line.start_with?("#{Auth::Base::ACCESS_COOKIE_KEY}=") }
    refresh_cookie_line = cookie_lines.find { |line| line.start_with?("#{Auth::Base::REFRESH_COOKIE_KEY}=") }

    assert access_cookie_line, "Logout response should include a Set-Cookie for the access cookie"
    assert refresh_cookie_line, "Logout response should include a Set-Cookie for the refresh cookie"
    assert_match(/max-age=0/i, access_cookie_line)
    assert_match(/max-age=0/i, refresh_cookie_line)

    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain
    post "/edge/v1/token/refresh",
         headers: { "Host" => @host, "Accept" => "application/json" },
         as: :json

    assert_response :unauthorized
    json = response.parsed_body

    assert_equal "invalid_refresh_token", json["error_code"]
  end

  test "logout remains idempotent when refresh token is already revoked" do
    token_record = UserToken.create!(user: @user)
    refresh_plain = token_record.rotate_refresh_token!
    token_record.revoke!

    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain
    delete sign_app_out_url(ri: "jp"), headers: {
      "Host" => @host,
      "X-TEST-CURRENT-USER" => @user.id,
    }

    assert_redirected_to sign_app_root_path(ri: "jp")
    assert_predicate token_record.reload.revoked_at, :present?
  end
end
