require "test_helper"

class Docs::Com::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get docs_com_root_url
    assert_select "h1", "Docs::Com::Roots#index"
    assert_select "a[href=?]", www_com_root_url
    assert_select "a[href=?]", docs_com_root_path
    assert_select "a[href=?]", news_org_root_url
    assert_select "a[href=?]", edit_www_com_preference_cookie_url
    assert_response :success
  end
end
