# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Org::Edge::V1::CsrfControllerTest < ActionDispatch::IntegrationTest
  test "returns csrf token payload" do
    get sign_org_edge_v1_csrf_url(ri: "jp")

    assert_response :success
    assert_not response.parsed_body["csrf_token"].to_s.empty?
  end

  test "csrf endpoint sets non-HttpOnly CSRF token cookie" do
    get sign_org_edge_v1_csrf_url(ri: "jp")

    assert_response :success

    # Check that Set-Cookie header contains the CSRF token cookie
    raw_header = response.headers["Set-Cookie"] || response.headers["set-cookie"]
    cookie_lines = raw_header.is_a?(Array) ? raw_header : raw_header.to_s.split("\n")
    csrf_cookie = cookie_lines.find { |line| line.start_with?("#{::Csrf::CSRF_COOKIE_KEY}=") }

    assert_predicate csrf_cookie, :present?, "CSRF cookie should be present in Set-Cookie header"
    assert_match(/SameSite=Lax/i, csrf_cookie, "CSRF cookie should have SameSite=Lax")
    assert_no_match(/HttpOnly/i, csrf_cookie, "CSRF cookie should NOT be HttpOnly")
  end

  test "csrf token and cookie match" do
    get sign_org_edge_v1_csrf_url(ri: "jp")

    assert_response :success

    token_from_json = response.parsed_body["csrf_token"]

    # Extract CSRF cookie token
    raw_header = response.headers["Set-Cookie"] || response.headers["set-cookie"]
    cookie_lines = raw_header.is_a?(Array) ? raw_header : raw_header.to_s.split("\n")
    csrf_line = cookie_lines.find { |line| line.start_with?("#{::Csrf::CSRF_COOKIE_KEY}=") }

    assert_predicate csrf_line, :present?, "CSRF cookie should be present"

    # Extract the token value from cookie (before semicolon and URL encoding)
    cookie_parts = csrf_line.split(";")
    cookie_key_value = cookie_parts.first.split("=", 2)
    token_from_cookie = CGI.unescape(cookie_key_value[1])

    assert_equal token_from_json, token_from_cookie, "JSON and cookie tokens should match"
  end
end
