# frozen_string_literal: true

require "test_helper"

class Sign::App::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get sign_app_configuration_url, headers: { "Host" => @host }

    assert_response :success
    assert_select "a[href^=?]", sign_app_configuration_google_path
    assert_select "a[href^=?]", sign_app_configuration_apple_path
  end
end
