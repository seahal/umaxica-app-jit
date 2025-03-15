# frozen_string_literal: true

require "test_helper"

module Org
  class StagingsControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get www_org_staging_url
      assert_response :success
      assert_select "p", "HASH =>#{ENV['COMMIT_HASH']}"
    end
  end
end
