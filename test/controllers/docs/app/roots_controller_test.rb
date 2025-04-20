require "test_helper"

class Docs::App::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get docs_app_root_url
    assert_response :success
  end
end
