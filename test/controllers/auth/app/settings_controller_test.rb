# frozen_string_literal: true

require "test_helper"

module Auth
  module App
    class SettingsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get auth_app_setting_url, headers: { "Host" => @host }
        assert_response :success
      end
    end
  end
end