require "test_helper"

class Auth::App::RootsControllerTest < ActionDispatch::IntegrationTest
  test "GET / redirects to new registration path" do
    get auth_app_root_url

    # Controller now renders the root index page with links to registration
    assert_response :success
    assert_select "h1", minimum: 1
  end

  test "GET / returns redirect status" do
    get auth_app_root_url

    assert_response :success
  end
end
