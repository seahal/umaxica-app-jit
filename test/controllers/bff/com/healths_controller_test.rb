# frozen_string_literal: true

require "test_helper"

module Bff
  module Com
    class HealthsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get bff_com_health_url

        assert_response :success
        assert_equal "OK", @response.body
      end

      test "should get show with postfix" do
        get bff_com_health_url(format: :html)

        assert_response :success
        assert_equal "OK", @response.body
      end
    end
  end
end
