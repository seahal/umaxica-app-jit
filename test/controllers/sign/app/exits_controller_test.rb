require "test_helper"

class Sign::App::ExitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end

  test "should get edit raises error without session" do
    get edit_sign_app_exit_url, headers: { "Host" => @host }
    assert_response :not_found
  end

  test "should destroy raises error without session" do
    delete sign_app_exit_url, headers: { "Host" => @host }
    assert_response :not_found
  end
end
