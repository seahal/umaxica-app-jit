# frozen_string_literal: true

require "test_helper"

class Sign::Org::InsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
  end

  test "should get new" do
    get new_sign_org_in_url, headers: { "Host" => @host }

    assert_response :success
  end

  test "renders turnstile widget" do
    get new_sign_org_in_url, headers: { "Host" => @host }

    assert_response :success
    assert_select "div[id^='cf-turnstile-']", count: 1
  end

  test "renders authentication links" do
    get new_sign_org_in_url, headers: { "Host" => @host }

    assert_response :success

    query = { lx: "ja", ri: "jp", tz: "jst", ct: "sy" }
    assert_select "a[href=?]", new_sign_org_in_passkey_path(query)
  end
end
