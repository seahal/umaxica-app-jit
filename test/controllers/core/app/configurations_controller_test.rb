# frozen_string_literal: true

require "test_helper"

class Core::App::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get core_app_configuration_url
    assert_response :success
  end
end
