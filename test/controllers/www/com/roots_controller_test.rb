# frozen_string_literal: true

require "test_helper"

module Com
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get www_com_root_url
      assert_response :success
      assert_select "a[href=?]", edit_www_com_preference_cookie_path
    end
  end
end
