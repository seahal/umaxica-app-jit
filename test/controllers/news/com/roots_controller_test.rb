require "test_helper"

class News::Com::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get news_com_root_url
    assert_select 'h1', 'News::Com::Roots#index'
    assert_response :success
  end
end
