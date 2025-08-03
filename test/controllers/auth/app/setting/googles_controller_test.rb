# frozen_string_literal: true

require "test_helper"

module Auth
  module App
    module Setting
      class GooglesControllerTest < ActionDispatch::IntegrationTest
        test "should get index" do
          get auth_app_setting_google_url
          assert_response :success
        end
      end
    end
  end
end
