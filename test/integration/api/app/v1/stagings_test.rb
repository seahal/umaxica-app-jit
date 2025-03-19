# frozen_string_literal: true

require "test_helper"

module App
  module V1
    class StagingsTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get api_app_v1_staging_url
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal false, json["staging"]
        assert_equal ENV.fetch("COMMIT_HASH", ""), json["id"]
      end
    end
  end
end
