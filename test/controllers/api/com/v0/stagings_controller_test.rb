# frozen_string_literal: true

require "test_helper"

module Api::Com::V0
    class StagingsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get api_com_v0_staging_url
        assert_response :success
      end
    end
end
