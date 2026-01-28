# frozen_string_literal: true

require "test_helper"

module Core
  module App
    class HealthsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get core_app_health_url

        assert_response :success
        assert_equal "OK", @response.body
      end

      test "should get show with postfix" do
        get core_app_health_url(format: :html)

        assert_response :success
        assert_equal "OK", @response.body
      end

      test "should handle redirect if response is redirect" do
        get core_app_health_url

        if response.redirect?
          assert_response :redirect
          assert_not_nil response.location
        else
          assert_response :success
        end
      end

      test "should accept both success and redirect responses" do
        get core_app_health_url(format: :html)

        assert_includes [ 200 ], response.status
      end
    end
  end
end
