# typed: false
# frozen_string_literal: true

require "test_helper"

class Core::Org::EmergencyControllersTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("MAIN_STAFF_URL", "main.org.localhost")
  end

  test "GET show renders app emergency pages" do
    get main_org_emergency_app_outage_url

    assert_response :success
    assert_select "h1", "Emergency App Outage"
  end

  test "GET show renders com emergency pages" do
    get main_org_emergency_com_outage_url

    assert_response :success
    assert_select "h1", "Emergency Com Outage"
  end

  test "GET show renders org emergency pages" do
    get main_org_emergency_org_outage_url

    assert_response :success
    assert_select "h1", "Emergency Org Outage"

    get main_org_emergency_org_token_url

    assert_response :success
    assert_select "h1", "Emergency Org Token"
  end

  test "PATCH and PUT update redirect to show" do
    patch main_org_emergency_app_outage_url

    assert_response :redirect
    assert_redirected_to main_org_emergency_app_outage_url

    patch main_org_emergency_com_outage_url

    assert_response :redirect
    assert_redirected_to main_org_emergency_com_outage_url

    patch main_org_emergency_org_outage_url

    assert_response :redirect
    assert_redirected_to main_org_emergency_org_outage_url

    put main_org_emergency_org_token_url

    assert_response :redirect
    assert_redirected_to main_org_emergency_org_token_url
  end
end
