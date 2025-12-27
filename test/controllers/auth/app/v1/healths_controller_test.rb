# frozen_string_literal: true

require "test_helper"
require "support/committee_helper"

module Auth
  module App
    module V1
      class HealthsControllerTest < ActionDispatch::IntegrationTest
        include CommitteeHelper

        test "returns success for default format" do
          get auth_app_v1_health_url

          assert_response :success
          assert_includes response.body, "OK"
        end

        test "returns success for explicit html format" do
          get auth_app_v1_health_url(format: :html)

          assert_response :success
          assert_includes response.body, "OK"
        end

        test "returns OK status payload for json format" do
          get auth_app_v1_health_url(format: :json)

          assert_response :success
          assert_equal "OK", response.parsed_body["status"]
        end

        test "raises error for unsupported yaml format" do
          get auth_app_v1_health_url(format: :yaml)

          assert_response :success
          assert_equal "OK", response.parsed_body["status"]
        end

        test "json response conforms to OpenAPI schema" do
          get auth_app_v1_health_url, headers: { "Accept" => "application/json" }

          assert_response :success
          assert_response_schema_confirm
        end
      end
    end
  end
end
