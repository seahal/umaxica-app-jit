# frozen_string_literal: true

require "test_helper"

module Api::Com::V1
  class StagingsTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get api_com_v1_staging_url(format: :json), headers: { "HOST" => ENV["API_CORPORATE_URL"] }
      assert_response :success
      json = response.parsed_body
      assert_equal false, json["staging"]
      assert_equal ENV.fetch("COMMIT_HASH", ""), json["id"]
    end

    test "should get show(html)" do
      get api_com_v1_staging_url(format: :html)
      assert_response :not_acceptable
    end

    test "should get show(normal)" do
      get api_com_v1_staging_url, headers: { "HOST" => ENV["API_CORPORATE_URL"] }
      assert_response :success
    end
  end
end
