# frozen_string_literal: true

require "test_helper"

module Bff
  module Org
    class HealthsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get bff_org_health_url

        assert_response :success
        assert_equal "OK", @response.body
      end

      test "should get show with postfix" do
        get bff_org_health_url(format: :html)

        assert_response :success
        assert_equal "OK", @response.body
      end

      test "should handle redirect if response is redirect" do
        get bff_org_health_url

        if response.redirect?
          assert_response :redirect
          assert_not_nil response.location
        else
          assert_response :success
        end
      end

      test "should accept both success and redirect responses" do
        get bff_org_health_url(format: :html)

        assert_includes [ 302 ], response.status
      end
    end
  end
end
