# frozen_string_literal: true

require "test_helper"

class Core::Org::EmergencyControllersTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("CORE_STAFF_URL", "www.org.localhost")
  end

  test "GET show renders app emergency pages" do
    get core_org_emergency_app_outage_url
    assert_response :success
    assert_select "h1", "Emergency App Outage"

    get core_org_emergency_app_token_url
    assert_response :success
    assert_select "h1", "Emergency App Token"
  end

  test "GET show renders com emergency pages" do
    get core_org_emergency_com_outage_url
    assert_response :success
    assert_select "h1", "Emergency Com Outage"

    get core_org_emergency_com_token_url
    assert_response :success
    assert_select "h1", "Emergency Com Token"
  end

  test "GET show renders org emergency pages" do
    get core_org_emergency_org_outage_url
    assert_response :success
    assert_select "h1", "Emergency Org Outage"

    get core_org_emergency_org_token_url
    assert_response :success
    assert_select "h1", "Emergency Org Token"
  end

  test "PATCH and PUT update redirect to show" do
    patch core_org_emergency_app_outage_url
    assert_response :redirect
    assert_redirected_to core_org_emergency_app_outage_url

    put core_org_emergency_app_token_url
    assert_response :redirect
    assert_redirected_to core_org_emergency_app_token_url

    patch core_org_emergency_com_outage_url
    assert_response :redirect
    assert_redirected_to core_org_emergency_com_outage_url

    put core_org_emergency_com_token_url
    assert_response :redirect
    assert_redirected_to core_org_emergency_com_token_url

    patch core_org_emergency_org_outage_url
    assert_response :redirect
    assert_redirected_to core_org_emergency_org_outage_url

    put core_org_emergency_org_token_url
    assert_response :redirect
    assert_redirected_to core_org_emergency_org_token_url
  end
end
