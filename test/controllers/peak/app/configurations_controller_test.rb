require "test_helper"

module Peak::App
  class ConfigurationsControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get peak_app_configuration_url

      assert_response :success
    end
  end
end
