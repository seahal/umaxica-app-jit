# frozen_string_literal: true

require "test_helper"

module Api
  module App
    module V1
      class HealthsControllerTest < ActionDispatch::IntegrationTest
        test "should get show" do
          get api_app_v1_health_url
          assert_equal "application/json", @response.media_type
          assert_response :success
        end
      end
    end
  end
end
