require "test_helper"


class Sign::App::Authentication::RecoveryCodesControllerTest < ActionDispatch::IntegrationTest
  # rubocop:disable Minitest/MultipleAssertions
  test "should get new" do
    get new_sign_app_authentication_recovery_url, headers: { "Host" => ENV["SIGN_SERVICE_URL"] }

    assert_select "h1", I18n.t("sign.app.authentication.recovery.new.page_title")
    assert_select "p", I18n.t("sign.app.authentication.recovery.new.description")
    assert_select "form" do |_element|
      assert_select "label[for=?]", "user_recovery_code_account_identifiable_information",
                    "Account identifiable information"
      assert_select "input[type=?][name=?]", "text", "user_recovery_code[account_identifiable_information]"
      assert_select "label[for=?]", "user_recovery_code_recovery_code", "Recovery code"
      assert_select "input[type=?][name=?]", "password", "user_recovery_code[recovery_code]"
      assert_select "div.cf-turnstile"
      assert_select "input[type=?]", "submit"
    end
    #    assert_select "a[href=?]", new_sign_app_authentication_path,                  I18n.t("sign.app.authentication.new.back")
    assert_response :success
  end
  # rubocop:enable Minitest/MultipleAssertions
end
