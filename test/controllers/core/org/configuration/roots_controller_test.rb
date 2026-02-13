# frozen_string_literal: true

require "test_helper"

class Core::Org::Configuration::RootsControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_statuses

  setup do
    host! ENV.fetch("SIGN_ORG_URL", ENV.fetch("CORE_STAFF_URL", "www.org.localhost"))
    @staff = staffs(:one)
  end

  test "redirects when refresh token is missing" do
    get "/configuration", params: { ri: "jp" }

    assert_response :redirect
    assert_match %r{/in/new\?}, response.headers["Location"]
    assert_match %r{rt=}, response.headers["Location"]
  end

  test "returns success when refresh token is valid" do
    token = StaffToken.create!(staff: @staff)
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = token.rotate_refresh_token!

    get "/configuration", params: { ri: "jp" }
    follow_redirect! if response.moved_permanently?

    assert_response :success
  end
end
