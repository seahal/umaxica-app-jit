require "test_helper"

class Www::Com::CookiesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_www_com_cookie_url
    assert_response :success
  end

  test "should get update" do
    assert true
  end
end
