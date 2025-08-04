# frozen_string_literal: true

require "test_helper"

class Auth::App::Setting::ApplesControllerTest < ActionDispatch::IntegrationTest
        test "should get index" do
          get auth_app_setting_apple_url
          assert_response :success
        end
end
