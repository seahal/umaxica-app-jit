# frozen_string_literal: true

require "test_helper"

module App
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get www_app_root_url
      assert_response :success
      # assert_select "a[href=?]", edit_www_app_preference_cookie_path
      #   assert_select "p", "© #{ Time.now.year } Umaxica."
    end

    test "Breadcrumbs" do
      get www_app_root_url
      #      assert_select "nav ul li a[href=?]", www_app_root_url
    end
  end
end
