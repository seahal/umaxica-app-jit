# frozen_string_literal: true

require "test_helper"

module Top::App
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should redirect to TOP_SERVICE_URL" do
      get top_app_root_url

      assert_response :redirect
      assert_redirected_to "https://#{ENV['EDGE_SERVICE_URL']}"
    end
  end
end
