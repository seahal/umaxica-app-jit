# frozen_string_literal: true

require "test_helper"

module App
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get www_app_root_url
      assert_response :success
    end
  end
end
