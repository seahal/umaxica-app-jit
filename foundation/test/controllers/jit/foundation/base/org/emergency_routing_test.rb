# typed: false
# frozen_string_literal: true

    require "test_helper"

    class Base::Org::EmergencyRoutingTest < ActionDispatch::IntegrationTest
      FOUNDATION_BASE_ORG_HOST = ENV.fetch("FOUNDATION_BASE_ORG_URL", "base.org.localhost")

      test "routes emergency app outage" do
        assert_routed("/emergency/app/outage", :get, "base/org/emergency/app/outages", "show")
        assert_routed("/emergency/app/outage", :patch, "base/org/emergency/app/outages", "update")
        assert_routed("/emergency/app/outage", :put, "base/org/emergency/app/outages", "update")
      end

      test "routes emergency com outage" do
        assert_routed("/emergency/com/outage", :get, "base/org/emergency/com/outages", "show")
        assert_routed("/emergency/com/outage", :patch, "base/org/emergency/com/outages", "update")
        assert_routed("/emergency/com/outage", :put, "base/org/emergency/com/outages", "update")
      end

      test "routes emergency org outage/token" do
        assert_routed("/emergency/org/outage", :get, "base/org/emergency/org/outages", "show")
        assert_routed("/emergency/org/outage", :patch, "base/org/emergency/org/outages", "update")
        assert_routed("/emergency/org/outage", :put, "base/org/emergency/org/outages", "update")

        assert_routed("/emergency/org/token", :get, "base/org/emergency/org/tokens", "show")
        assert_routed("/emergency/org/token", :patch, "base/org/emergency/org/tokens", "update")
        assert_routed("/emergency/org/token", :put, "base/org/emergency/org/tokens", "update")
      end

      private

      def assert_routed(path, method, expected_controller, expected_action)
        send(method, "http://#{FOUNDATION_BASE_ORG_HOST}#{path}")

        assert_equal expected_controller, request.path_parameters[:controller]
        assert_equal expected_action, request.path_parameters[:action]
      end
    end
  end
end
