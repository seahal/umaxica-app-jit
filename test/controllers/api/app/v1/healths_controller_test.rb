require "test_helper"

module Api
  module App
    module V1
      class HealthsControllerTest < ActionDispatch::IntegrationTest
        test "returns success for default format" do
          get api_app_v1_health_url

          assert_response :ok
          assert_includes response.body, "OK"
        end

        test "returns success for explicit html format" do
          get api_app_v1_health_url(format: :html)

          assert_response :ok
          assert_includes response.body, "OK"
        end

        test "returns OK status payload for json format" do
          get api_app_v1_health_url(format: :json)

          assert_response :ok
          assert_equal "OK", response.parsed_body["status"]
          assert_nil response.parsed_body["errors"]
        end

        test "returns OK status for yaml format" do
          get api_app_v1_health_url(format: :yaml)

          assert_response :ok
          assert_equal "OK", response.parsed_body["status"]
        end

        test "returns 422 when database connection fails" do
          skip "Database health check is currently disabled in Health concern"
          # Stub database connection to raise an error
          ActiveRecord::Base.connection.stub(:execute, ->(_sql) { raise ActiveRecord::ConnectionNotEstablished, "Connection failed" }) do
            get api_app_v1_health_url(format: :json)

            assert_unhealthy_response_includes "Database connection failed"
          end
        end

        test "returns 422 when Redis connection fails if Redis is configured" do
          skip "Redis not configured" unless defined?(REDIS_CLIENT)

          # Stub Redis connection to raise an error
          REDIS_CLIENT.stub(:ping, -> { raise Redis::CannotConnectError, "Connection refused" }) do
            get api_app_v1_health_url(format: :json)

            assert_response :unprocessable_entity
            body = response.parsed_body

            assert_equal "UNHEALTHY", body["status"]
            assert_includes body["errors"].join(", "), "Redis connection failed"
          end
        end
      end
    end
  end
end
