require "test_helper"

class Auth::App::Authentication::RecoveryCodesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_app_authentication_recovery_url, headers: { "Host" => ENV["AUTH_SERVICE_URL"] }
    assert_select "h1", "Auth::App::Authentication::RecoveryCodes#new"
    assert_select "p", "Find me in app/views/auth/app/authentication/recovery_codes/new.html.erb"
    assert_select "form" do |_element|
      assert_select "label[for=?]", "user_recovery_code_account_identifiable_information",
                    "Account identifiable information"
      assert_select "input[type=?][name=?]", "text", "user_recovery_code[account_identifiable_information]"
      assert_select "label[for=?]", "user_recovery_code_recovery_code", "Recovery code"
      assert_select "input[type=?][name=?]", "password", "user_recovery_code[recovery_code]"
      assert_select "div.cf-turnstile"
      assert_select "input[type=?]", "submit"
    end
    assert_select "a[href=?]", new_auth_app_authentication_path, I18n.t("www.app.authentication.new.back")
    assert_response :success
  end
end
