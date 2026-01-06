# frozen_string_literal: true

require "test_helper"

class Apex::Com::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get apex_com_configuration_url
    assert_response :success
  end
end
