# frozen_string_literal: true

require "test_helper"

class Sign::Org::PasskeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
  end

  test "should get new" do
    get new_sign_org_in_passkey_url, headers: { "Host" => @host }

    assert_response :success
  end

  test "new authentication passkey page renders Turnstile widget" do
    get new_sign_org_in_passkey_url, headers: { "Host" => @host }

    assert_response :success
    assert_select "div[id^='cf-turnstile-']", count: 1
  end
end
