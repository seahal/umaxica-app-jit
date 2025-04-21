require "test_helper"

class News::Org::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get news_org_root_url
    assert_select 'h1', 'News::Org::Roots#index'
    assert_response :success
  end
end
