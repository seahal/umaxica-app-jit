# frozen_string_literal: true

require "test_helper"

module Org
  class HealthsControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get www_org_health_url
      assert_response :success
      assert_equal "OK", @response.body
      assert_select "a[href=?]", www_app_root_path, count: 0
    end

    test "should not get show when required json file" do
      assert_raise do
        get www_org_health_url(format: :json)
      end
    end
  end
end
