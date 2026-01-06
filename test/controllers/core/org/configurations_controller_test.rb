# frozen_string_literal: true

require "test_helper"

class Core::Org::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get core_org_configuration_url
    assert_response :success
  end
end
