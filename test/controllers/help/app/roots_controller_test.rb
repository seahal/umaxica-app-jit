# frozen_string_literal: true

require "test_helper"

module Help
module App
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get help_app_root_url
      assert_response :success
    end
  end
end
end
