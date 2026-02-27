# typed: false
# frozen_string_literal: true

require "test_helper"
require "support/committee_helper"

module Sign
  module App
    module Client
      module V1
        class HealthsControllerTest < ActionDispatch::IntegrationTest
          include CommitteeHelper

          test "returns success for default format" do
            get sign_app_client_v1_health_url(ri: "jp")

            assert_response :success
            assert_includes response.body, "OK"
          end

          test "returns success for explicit html format" do
            get sign_app_client_v1_health_url(format: :html, ri: "jp")

            assert_response :success
            assert_includes response.body, "OK"
          end

          test "returns OK status payload for json format" do
            get sign_app_client_v1_health_url(format: :json, ri: "jp")

            assert_response :success
            assert_equal "OK", response.parsed_body["status"]
          end

          test "returns OK status for yaml format" do
            get sign_app_client_v1_health_url(format: :yaml, ri: "jp")

            assert_response :success
            assert_equal "OK", response.parsed_body["status"]
          end

          test "json response conforms to OpenAPI schema" do
            get sign_app_client_v1_health_url(ri: "jp"), headers: { "Accept" => "application/json" }

            assert_response :success
            assert_response_schema_confirm
          end
        end
      end
    end
  end
end
