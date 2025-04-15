require "test_helper"

class Www::App::CookiesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_www_app_cookie_url
    assert_response :success
  end

  test "should get update" do
    assert true
  end
end
