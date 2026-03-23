# typed: false
# frozen_string_literal: true

require "test_helper"

module Core
  module Org
    class HealthsControllerTest < ActionDispatch::IntegrationTest
      test "should render healthy status" do
        with_stubbed_health_status([200, "OK"]) do
          get core_org_health_url

          assert_response :success
          assert_includes response.body, "OK"
          assert_match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/, response.body)
        end
      end

      test "should render unhealthy status with dependency details" do
        with_stubbed_health_status([503, "UNHEALTHY", ["Database ActivityRecord(writing) unavailable"]]) do
          get core_org_health_url(format: :html)

          assert_response :service_unavailable
          assert_includes response.body, "UNHEALTHY"
          assert_includes response.body, "Database ActivityRecord(writing) unavailable"
        end
      end

      private

      def with_stubbed_health_status(result)
        Core::Org::HealthsController.send(:define_method, :get_status) { result }
        yield
      ensure
        if Core::Org::HealthsController.private_method_defined?(:get_status) ||
            Core::Org::HealthsController.method_defined?(:get_status, false)
          Core::Org::HealthsController.send(:remove_method, :get_status)
        end
      end
    end
  end
end
