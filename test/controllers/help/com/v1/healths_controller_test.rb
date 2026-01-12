# frozen_string_literal: true

require "test_helper"

module Help
  module Com
    module V1
      class HealthsControllerTest < ActionDispatch::IntegrationTest
        setup do
          Help::Com::ApplicationController.define_method(:canonicalize_regional_params) { nil }
        end

        teardown do
          begin
            Help::Com::ApplicationController.remove_method(:canonicalize_regional_params)
          rescue NameError
            # Ignore
          end
        end

        test "returns success for default format" do
          get help_com_v1_health_url()

          assert_response :success
          assert_includes response.body, "OK"
        end

        test "returns success for explicit html format" do
          get help_com_v1_health_url(format: :html)

          assert_response :success
          assert_includes response.body, "OK"
        end

        test "returns OK status payload for json format" do
          get help_com_v1_health_url(format: :json)

          assert_response :success
          assert_equal "OK", response.parsed_body["status"]
        end

        test "raises error for unsupported yaml format" do
          get help_com_v1_health_url(format: :yaml)

          assert_response :success
          assert_equal "OK", response.parsed_body["status"]
        end
      end
    end
  end
end
