require "test_helper"

class Www::App::Authentication::RecoveryCodesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_www_app_authentication_recovery_code_url
    assert_response :success
  end
end
