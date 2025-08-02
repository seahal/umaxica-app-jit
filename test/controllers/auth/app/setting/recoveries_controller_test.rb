# frozen_string_literal: true

require "test_helper"

module Auth
  module App
    module Setting
      class RecoveriesControllerTest < ActionDispatch::IntegrationTest
        test "should get index" do
          get auth_app_setting_recoveries_url, headers: { "Host" => @host }
          assert_response :success
        end
      end
    end
  end
end