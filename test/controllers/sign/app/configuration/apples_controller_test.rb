# frozen_string_literal: true

require "test_helper"

module Sign::App::Configuration
  class ApplesControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get sign_app_configuration_apple_url(ri: "jp")

      assert_response :success
    end
  end
end
