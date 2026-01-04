# frozen_string_literal: true

require "test_helper"

class Sign::Org::RecoveriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
  end

  test "should get new" do
    get new_sign_org_authentication_recovery_url, headers: { "Host" => @host }

    assert_response :success
  end

  test "new recovery page renders Turnstile widget" do
    get new_sign_org_authentication_recovery_url, headers: { "Host" => @host }

    assert_response :success
    assert_select "div[id^='cf-turnstile-']", count: 1
  end

  test "should render new on create" do
    post sign_org_authentication_recovery_url,
         params: {
           recovery_form: {
             account_identifiable_information: "staff@example.com",
             recovery_code: "123456",
           },
         },
         headers: { "Host" => @host }

    assert_response :unprocessable_content
  end
end
