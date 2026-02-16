# frozen_string_literal: true

require "test_helper"

class SurfaceCookieDomainIntegrationTest < ActionDispatch::IntegrationTest
  test "app surface jit cookies use Domain=.localhost" do
    with_env(
      "COOKIE_DOMAIN_APP" => "app.localhost",
      "COOKIE_DOMAIN_ORG" => "org.localhost",
      "COOKIE_DOMAIN_COM" => "com.localhost",
    ) do
      host! "app.localhost"
      get help_app_root_path
      follow_redirect! if response.redirect?

      assert_response :success
      assert_cookie_domain_for_jit!(".localhost")
    end
  end

  test "org surface jit cookies use Domain=.localhost" do
    with_env(
      "COOKIE_DOMAIN_APP" => "app.localhost",
      "COOKIE_DOMAIN_ORG" => "org.localhost",
      "COOKIE_DOMAIN_COM" => "com.localhost",
    ) do
      host! "org.localhost"
      get help_org_root_path
      follow_redirect! if response.redirect?

      assert_response :success
      assert_cookie_domain_for_jit!(".localhost")
    end
  end

  test "surface middleware stores detected surface in request env" do
    host! "app.localhost"
    get test_surface_path
    assert_response :success
    assert_equal "app", response.parsed_body["surface"]

    host! "org.localhost"
    get test_surface_path
    assert_response :success
    assert_equal "org", response.parsed_body["surface"]
  end

  private

  def assert_cookie_domain_for_jit!(expected_domain)
    lines = response_cookie_lines
    jit_lines = lines.select { |line| line.include?("jit_") }

    assert_predicate jit_lines, :any?, "expected at least one jit_* Set-Cookie header"
    assert jit_lines.any? { |line| line.downcase.include?("domain=#{expected_domain.downcase}") },
           "expected at least one jit_* cookie with Domain=#{expected_domain}, got: #{jit_lines.inspect}"
  end

  def response_cookie_lines
    raw_header = response.headers["Set-Cookie"] || response.headers["set-cookie"]
    case raw_header
    when Array then raw_header
    when String then raw_header.split("\n")
    else []
    end
  end

  def with_env(vars)
    original = {}
    vars.each_key { |key| original[key] = ENV[key] }

    vars.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end

    yield
  ensure
    original.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end
end
