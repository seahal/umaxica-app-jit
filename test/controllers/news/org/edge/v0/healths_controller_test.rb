# typed: false
# frozen_string_literal: true

require "test_helper"

module News
  module Org
    module Edge
      module V0
        class HealthsControllerTest < ActionDispatch::IntegrationTest
          test "returns success for default format" do
            get news_org_edge_v0_health_url

            assert_response :success
            assert_includes response.body, "OK"
            assert_match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/, response.body)
          end

          test "returns success for explicit html format" do
            get news_org_edge_v0_health_url(format: :html)

            assert_response :success
            assert_includes response.body, "OK"
            assert_match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/, response.body)
          end

          test "returns OK status payload for json format" do
            get news_org_edge_v0_health_url(format: :json)

            assert_response :success
            assert_equal "OK", response.parsed_body["status"]
            assert_match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/, response.parsed_body["timestamp"])
          end

          test "raises error for unsupported yaml format" do
            get news_org_edge_v0_health_url(format: :yaml)

            assert_equal "OK", response.parsed_body["status"]

            assert_match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/, response.parsed_body["timestamp"])
          end
        end
      end
    end
  end
end
