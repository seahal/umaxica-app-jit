# frozen_string_literal: true

require "test_helper"

module Apex
  class StagingsControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get apex_app_staging_url
      assert_response :success
      assert_select "p", "HASH =>#{ENV['COMMIT_HASH']}"
    end
  end
end
