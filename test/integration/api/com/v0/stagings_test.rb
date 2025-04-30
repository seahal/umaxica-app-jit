# frozen_string_literal: true

require "test_helper"

module Api::Com::V0
  class StagingsTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get api_com_v0_staging_url
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal false, json["staging"]
      assert_equal ENV.fetch("COMMIT_HASH", ""), json["id"]
    end
  end
end
