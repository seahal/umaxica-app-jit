# frozen_string_literal: true

require "test_helper"

module Top
  module Org
    class HealthsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get top_org_health_url

        assert_response :success
        assert_equal "OK", @response.body
        # assert_select "a[href=?]", top_org_root_path, count: 0
      end

      test "should get show with postfix" do
        get top_org_health_url(format: :html)

        assert_response :success
        assert_equal "OK", @response.body
        #   assert_select "a[href=?]", top_org_root_path, count: 0
      end
    end
  end
end
