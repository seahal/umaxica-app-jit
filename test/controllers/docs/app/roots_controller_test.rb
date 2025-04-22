require "test_helper"

class Docs::App::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get docs_app_root_url
    assert_select "h1", "Docs::App::Roots#index"
    assert_select "a[href=?]", docs_app_term_path
    assert_select "a[href=?]", docs_app_privacy_path
    assert_response :success
  end

  test "should get common layouts" do
    get docs_app_root_url
    assert_response :success
    assert_select "a[href=?]", www_app_root_url
    assert_select "a[href=?]", docs_app_root_url
    assert_select "a[href=?]", news_app_root_url
    assert_select "a[href=?]", edit_www_app_preference_cookie_url
    assert_select "a[href=?]", news_app_root_url
    assert_select "p", "© #{ Time.now.year } Umaxica."
  end
end
