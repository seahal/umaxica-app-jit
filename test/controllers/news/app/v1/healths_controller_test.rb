# frozen_string_literal: true

require "test_helper"

module News
  module App
    module V1
      class HealthsControllerTest < ActionDispatch::IntegrationTest
        test "returns success for default format" do
          get news_app_v1_health_url

          assert_response :success
          assert_includes response.body, "OK"
        end

        test "returns success for explicit html format" do
          get news_app_v1_health_url(format: :html)

          assert_response :success
          assert_includes response.body, "OK"
        end

        test "returns OK status payload for json format" do
          get news_app_v1_health_url(format: :json)

          assert_response :success
          assert_equal "OK", response.parsed_body["status"]
        end

        test "raises error for unsupported yaml format" do
          get news_app_v1_health_url(format: :yaml)

          assert_response :success
          assert_equal "OK", response.parsed_body["status"]
        end
      end
    end
  end
end
