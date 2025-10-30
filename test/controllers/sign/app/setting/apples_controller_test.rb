# frozen_string_literal: true

require "test_helper"

class Sign::App::Setting::ApplesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sign_app_setting_apple_url

    assert_response :success
  end
end
