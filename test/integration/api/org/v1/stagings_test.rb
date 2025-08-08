# frozen_string_literal: true

require "test_helper"

class Api::Org::V1::StagingsTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get api_org_v1_staging_url
    assert_response :success
    json = response.parsed_body
    assert_equal false, json["staging"]
    assert_equal ENV.fetch("COMMIT_HASH", ""), json["id"]
  end
end
