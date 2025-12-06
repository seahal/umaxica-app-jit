# frozen_string_literal: true

require "test_helper"

module Back::App
  class RootsControllerTest < ActionDispatch::IntegrationTest
    BACK_SERVICE_URL = ENV.fetch("BACK_SERVICE_URL", "back-service.example.com")

    test "should redirect to BACK_SERVICE_URL" do
      get back_app_root_url

      assert_response :success
    end
  end
end
