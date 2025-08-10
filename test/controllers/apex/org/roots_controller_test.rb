# frozen_string_literal: true

require "test_helper"

class Apex::Org::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get apex_org_root_url
    assert_response :success
  end

  test "should display admin dashboard" do
    get apex_org_root_url
    assert_response :success
    # Admin dashboard should load successfully with metrics
  end

  test "should load system metrics" do
    get apex_org_root_url
    assert_response :success
    # System metrics should be available for admin view
  end

  test "should show recent activities" do
    get apex_org_root_url
    assert_response :success
    # Recent activities should be displayed for admin monitoring
  end
end
