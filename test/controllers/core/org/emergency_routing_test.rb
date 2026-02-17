# frozen_string_literal: true

require "test_helper"

class Core::Org::EmergencyRoutingTest < ActionDispatch::IntegrationTest
  CORE_STAFF_HOST = ENV.fetch("CORE_STAFF_URL", "www.org.localhost")

  test "routes emergency app outage" do
    assert_routed("/emergency/app/outage", :get, "core/org/emergency/app/outages", "show")
    assert_routed("/emergency/app/outage", :patch, "core/org/emergency/app/outages", "update")
    assert_routed("/emergency/app/outage", :put, "core/org/emergency/app/outages", "update")
  end

  test "routes emergency com outage" do
    assert_routed("/emergency/com/outage", :get, "core/org/emergency/com/outages", "show")
    assert_routed("/emergency/com/outage", :patch, "core/org/emergency/com/outages", "update")
    assert_routed("/emergency/com/outage", :put, "core/org/emergency/com/outages", "update")
  end

  test "routes emergency org outage/token" do
    assert_routed("/emergency/org/outage", :get, "core/org/emergency/org/outages", "show")
    assert_routed("/emergency/org/outage", :patch, "core/org/emergency/org/outages", "update")
    assert_routed("/emergency/org/outage", :put, "core/org/emergency/org/outages", "update")

    assert_routed("/emergency/org/token", :get, "core/org/emergency/org/tokens", "show")
    assert_routed("/emergency/org/token", :patch, "core/org/emergency/org/tokens", "update")
    assert_routed("/emergency/org/token", :put, "core/org/emergency/org/tokens", "update")
  end

  private

  def assert_routed(path, method, expected_controller, expected_action)
    send(method, "http://#{CORE_STAFF_HOST}#{path}")

    assert_equal expected_controller, request.path_parameters[:controller]
    assert_equal expected_action, request.path_parameters[:action]
  end
end
