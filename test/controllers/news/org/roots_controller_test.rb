require "test_helper"

class News::Org::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get news_org_root_url
    assert_response :success
  end
end
