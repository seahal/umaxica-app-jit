# typed: false
# frozen_string_literal: true

    require "test_helper"

    class Base::Org::EmergencyControllersTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("FOUNDATION_BASE_ORG_URL", "base.org.localhost")
      end

      test "GET show renders app emergency pages" do
        get foundation.base_org_emergency_app_outage_url

        assert_response :success
        assert_select "h1", "Emergency App Outage"
      end

      test "GET show renders com emergency pages" do
        get foundation.base_org_emergency_com_outage_url

        assert_response :success
        assert_select "h1", "Emergency Com Outage"
      end

      test "GET show renders org emergency pages" do
        get foundation.base_org_emergency_org_outage_url

        assert_response :success
        assert_select "h1", "Emergency Org Outage"

        get foundation.base_org_emergency_org_token_url

        assert_response :success
        assert_select "h1", "Emergency Org Token"
      end

      test "PATCH and PUT update redirect to show" do
        patch foundation.base_org_emergency_app_outage_url

        assert_response :redirect
        assert_redirected_to foundation.base_org_emergency_app_outage_url

        patch foundation.base_org_emergency_com_outage_url

        assert_response :redirect
        assert_redirected_to foundation.base_org_emergency_com_outage_url

        patch foundation.base_org_emergency_org_outage_url

        assert_response :redirect
        assert_redirected_to foundation.base_org_emergency_org_outage_url

        put foundation.base_org_emergency_org_token_url

        assert_response :redirect
        assert_redirected_to foundation.base_org_emergency_org_token_url
      end
    end
  end
end
