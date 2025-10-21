require "test_helper"

class Sign::App::Authentication::ApplesControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to apple sign" do
    get new_sign_app_authentication_apple_url, headers: { "Host" => ENV["SIGN_SERVICE_URL"] }
    assert_response :redirect
    assert_redirected_to "/sign/apple"
  end

  # test "create should redirect to apple sign" do
  #   post sign_app_authentication_apple_url, headers: { "Host" => ENV["SIGN_SERVICE_URL"] }
  #   assert_response :redirect
  #   assert_redirected_to "/sign/apple"
  # end
end
