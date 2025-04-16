require "test_helper"

class Www::Org::CookiesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_www_org_cookie_url
    assert_response :success
  end

  test "should get update" do
    assert true
  end
end
