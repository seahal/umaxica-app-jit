# frozen_string_literal: true

require "test_helper"

module Org
  module V1
    class HealthsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get org_health_url
        assert_response :success
      end

      test "should not get show when required json file" do
        get org_health_url
        assert_raises do
          JSON.parse(response.body)
        end
      end
    end
  end
end
