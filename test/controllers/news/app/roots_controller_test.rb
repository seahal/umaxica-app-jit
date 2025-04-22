require "test_helper"

class News::App::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get news_app_root_url
    assert_select "h1", "News::App::Roots#index"
    assert_select "a[href=?]", www_app_root_url
    assert_select "a[href=?]", news_app_root_path
    assert_select "a[href=?]", docs_app_root_url
    assert_select "a[href=?]", edit_www_app_preference_cookie_url
    assert_select "p", "© #{ Time.now.year } Umaxica."
    assert_response :success
  end


  test "Breadcrumbs" do
    get news_app_root_url
    assert_select "nav ul li a[href=?]", www_app_root_url
    assert_select "nav ul li a[href=?]", news_app_root_url
  end
end
