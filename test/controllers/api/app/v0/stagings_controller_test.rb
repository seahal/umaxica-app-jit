# frozen_string_literal: true

require "test_helper"

module Api::App
  module V0
    class StagingsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get api_app_v0_staging_url
        assert_response :success
      end
    end
  end
end
