require "test_helper"

module Apex::App
  class ConfigurationsControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get apex_app_configuration_url

      assert_response :success
    end
  end
end
