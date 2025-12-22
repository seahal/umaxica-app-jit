require "test_helper"

class Auth::Org::RecoveriesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_org_authentication_recovery_url, headers: { "Host" => ENV["AUTH_STAFF_URL"] }

    assert_response :success
  end

  test "new recovery page renders Turnstile widget" do
    get new_auth_org_authentication_recovery_url, headers: { "Host" => ENV["AUTH_STAFF_URL"] }

    assert_response :success
    assert_select "div[id^='cf-turnstile-']", count: 1
  end

  test "should render new on create" do
    post auth_org_authentication_recovery_url,
         params: {
           recovery_form: {
             account_identifiable_information: "staff@example.com",
             recovery_code: "123456"
           }
         },
         headers: { "Host" => ENV["AUTH_STAFF_URL"] }

    assert_response :unprocessable_content
  end
end
