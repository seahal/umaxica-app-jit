# frozen_string_literal: true

require "test_helper"

module Net
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get www_app_root_url
      assert_response :redirect
    end
  end
end
