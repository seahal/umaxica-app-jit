# frozen_string_literal: true

require "test_helper"

class Auth::App::SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get auth_app_setting_url, headers: { "Host" => @host }
    assert_response :success
  end
end
