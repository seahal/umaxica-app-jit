require "test_helper"

class News::Org::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get news_org_root_url
    assert_select "h1", "News::Org::Roots#index"
    assert_select "a[href=?]", www_org_root_url
    assert_select "a[href=?]", news_org_root_path
    assert_select "a[href=?]", docs_org_root_url
    assert_select "a[href=?]", edit_www_org_preference_cookie_url
    assert_select "p", "© #{ Time.now.year } Umaxica."
    assert_response :success
  end
  test "Breadcrumbs" do
    get news_org_root_url
    assert_select "nav ul li a[href=?]", www_org_root_url
    assert_select "nav ul li a[href=?]", news_org_root_url
  end
end
