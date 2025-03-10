# frozen_string_literal: true

require "test_helper"

module Com
  module V1
    class StagingsControllerTest < ActionDispatch::IntegrationTest
      test "should get show for api" do
        get api_com_v1_health_url
        assert_response :success
      end
    end
  end
end
