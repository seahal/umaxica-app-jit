require "test_helper"

class Docs::Com::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get docs_com_root_url
    assert_select "h1", "Docs::Com::Roots#index"
    # assert_select "a[href=?]", docs_com_terms_path
    # assert_select "a[href=?]", docs_com_privacy_path
    assert_response :success
  end


  test "should get common layouts" do
    get docs_com_root_url
    assert_select "a[href=?]", www_com_root_url
    assert_select "a[href=?]", docs_com_root_path
    assert_select "a[href=?]", news_org_root_url
    assert_select "a[href=?]", edit_www_com_preference_cookie_url
    assert_select "p", "© #{ Time.now.year } Umaxica."
    assert_response :success
  end


  test "Breadcrumbs" do
    get docs_com_root_url
    assert_select "nav ul li a[href=?]", www_com_root_url
    assert_select "nav ul li a[href=?]", docs_com_root_url
  end
end
