require "test_helper"

class News::App::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get news_app_root_url
    assert_response :success
  end
end
