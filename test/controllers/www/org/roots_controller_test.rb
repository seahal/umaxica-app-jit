# frozen_string_literal: true

require "test_helper"

module Org
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get www_org_root_url
      assert_select "a[href=?]", edit_www_org_cookie_path
      assert_response :success
    end
  end
end
