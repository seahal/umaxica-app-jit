# frozen_string_literal: true

require "test_helper"

class Auth::App::Setting::GooglesControllerTest < ActionDispatch::IntegrationTest
        test "should get index" do
          get auth_app_setting_google_url
          assert_response :success
        end
end
