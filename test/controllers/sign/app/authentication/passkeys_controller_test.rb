require "test_helper"

class Sign::App::Authentication::PasskeysControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_sign_app_authentication_passkey_url, headers: { "Host" => ENV["SIGN_SERVICE_URL"] }
    assert_response :success
    #    assert_select "a[href=?]", new_sign_app_authentication_path,                 I18n.t("sign.app.authentication.new.back")
  end
end
