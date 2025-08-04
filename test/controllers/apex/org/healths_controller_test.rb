# frozen_string_literal: true

require "test_helper"

class Apex::Org::HealthsControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get apex_org_health_url
      assert_response :success
      assert_equal "OK", @response.body
      # assert_select "a[href=?]", apex_org_root_path, count: 0
    end

    test "should get show with postfix" do
      get apex_org_health_url(format: :html)
      assert_response :success
      assert_equal "OK", @response.body
      #   assert_select "a[href=?]", apex_org_root_path, count: 0
    end

    test "should not get show when required json file" do
      assert_raise do
        get apex_org_health_url(format: :json)
      end
    end
end
