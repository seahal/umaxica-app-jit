require "test_helper"

class News::Com::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get news_com_root_url
    assert_select "h1", "News::Com::Roots#index"
    assert_select "a[href=?]", www_com_root_url
    assert_select "a[href=?]", news_com_root_url
    assert_select "a[href=?]", docs_com_root_url
    assert_select "a[href=?]", edit_www_com_preference_cookie_url
    assert_response :success
  end
end
