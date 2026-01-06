# frozen_string_literal: true

require "test_helper"

class Core::Com::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get core_com_configuration_url
    assert_response :success
  end
end
