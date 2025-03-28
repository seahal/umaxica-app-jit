# frozen_string_literal: true

require "test_helper"

module Org
  module V0
    class StagingsTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get api_org_v0_staging_url
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal false, json["staging"]
        assert_equal ENV.fetch("COMMIT_HASH", ""), json["id"]
      end
    end
  end
end
