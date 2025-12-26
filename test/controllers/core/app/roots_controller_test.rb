# frozen_string_literal: true

require "test_helper"

module Core::App
  class RootsControllerTest < ActionDispatch::IntegrationTest
    CORE_SERVICE_URL = ENV.fetch("CORE_SERVICE_URL", ENV.fetch("BACK_SERVICE_URL", "back-service.example.com"))

    test "should redirect to CORE_SERVICE_URL" do
      get core_app_root_url

      assert_response :success
    end
  end
end
