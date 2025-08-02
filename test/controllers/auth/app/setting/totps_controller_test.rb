# frozen_string_literal: true

require "test_helper"

module Auth
  module App
    module Setting
      class TotpsControllerTest < ActionDispatch::IntegrationTest

        test "should get index" do
          get auth_app_setting_totps_url, headers: { "Host" => @host }
          assert_response :success
        end
      end
    end
  end
end