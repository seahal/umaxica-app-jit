# frozen_string_literal: true

require "test_helper"

module Auth::App::Setting
  class ApplesControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get auth_app_setting_apple_url

      assert_response :success
    end
  end
end
