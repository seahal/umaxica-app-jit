# frozen_string_literal: true

require "test_helper"

module Org
  module V1
    class HealthTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get api_org_v1_health_url(format: :html)
        assert_response :success
        assert_equal "OK", @response.body
      end

      test "should get show when required json file" do
        get api_org_v1_health_url(format: :json)
        assert_response :success
        assert_nothing_raised do
          assert_equal "OK", JSON.parse(response.body)["status"]
        end
      end
    end
  end
end
