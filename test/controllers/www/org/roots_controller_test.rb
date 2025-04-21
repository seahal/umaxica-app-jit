# frozen_string_literal: true

require "test_helper"

module Org
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get www_org_root_url
      assert_response :success
      assert_select "a[href=?]", edit_www_org_preference_cookie_path

      assert_select "p", "© #{ Time.now.year } Umaxica."
    end
  end
end
