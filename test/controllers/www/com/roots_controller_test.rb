# frozen_string_literal: true

require "test_helper"

module Com
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get www_com_root_url
      assert_response :success
      assert_select "p", "© #{ Time.now.year } Umaxica."
      assert_select "a[href=?]", edit_www_com_preference_cookie_path
    end

    test "Breadcrumbs" do
      get www_com_root_url
      assert_select "nav ul li a[href=?]", www_com_root_url
    end
  end
end
