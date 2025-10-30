# frozen_string_literal: true

require "test_helper"

class Sign::App::SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get sign_app_setting_url, headers: { "Host" => @host }

    assert_response :success
  end
end
