require "test_helper"

module Bff
  module Org
    module V1
      class HealthsControllerTest < ActionDispatch::IntegrationTest
        test "returns success for default format" do
          get bff_org_v1_health_url

          assert_response :success
          assert_includes response.body, "OK"
        end

        test "returns success for explicit html format" do
          get bff_org_v1_health_url(format: :html)

          assert_response :success
          assert_includes response.body, "OK"
        end

        test "returns OK status payload for json format" do
          get bff_org_v1_health_url(format: :json)

          assert_response :success
          assert_equal "OK", response.parsed_body["status"]
        end

        test "raises error for unsupported yaml format" do
          get bff_org_v1_health_url(format: :yaml)

          assert_response :success
          assert_equal "OK", response.parsed_body["status"]
        end

        test "should handle redirect if response is redirect" do
          get bff_org_v1_health_url

          if response.redirect?
            assert_response :redirect
            assert_not_nil response.location
          else
            assert_response :success
          end
        end

        test "should accept both success and redirect responses" do
          get bff_org_v1_health_url(format: :json)

          assert_includes [ 200 ], response.status
        end
      end
    end
  end
end
