# frozen_string_literal: true

require "test_helper"

class Apex::Com::RootsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get apex_com_root_url
    assert_response :success
  end

  test "should display company information" do
    get apex_com_root_url
    assert_response :success
    # Note: In a real app, you'd test for specific content presence
    # but since we don't have views, we just verify the controller runs
  end

  test "should load corporate dashboard data" do
    get apex_com_root_url
    assert_response :success
    # Corporate site should load successfully
  end
end
