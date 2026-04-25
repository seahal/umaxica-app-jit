# typed: false
# frozen_string_literal: true

module Jit
  module Zenith
    require "test_helper"

    class Jit::Zenith::Acme::Org::Emergency::CachesControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("ZENITH_ACME_ORG_URL", "org.localhost")
      end

      test "routes emergency cache endpoints to acme org controllers" do
        get "http://#{ENV.fetch("ZENITH_ACME_ORG_URL", "org.localhost")}/emergency/app/cache"

        assert_equal "acme/org/emergency/app/caches", request.path_parameters[:controller]
        assert_equal "show", request.path_parameters[:action]

        get "http://#{ENV.fetch("ZENITH_ACME_ORG_URL", "org.localhost")}/emergency/com/cache"

        assert_equal "acme/org/emergency/com/caches", request.path_parameters[:controller]
        assert_equal "show", request.path_parameters[:action]

        get "http://#{ENV.fetch("ZENITH_ACME_ORG_URL", "org.localhost")}/emergency/org/cache"

        assert_equal "acme/org/emergency/org/caches", request.path_parameters[:controller]
        assert_equal "show", request.path_parameters[:action]
      end

      test "GET show returns success for all emergency cache controllers" do
        get zenith.acme_org_emergency_app_cache_url

        assert_response :success

        get zenith.acme_org_emergency_com_cache_url

        assert_response :success

        get zenith.acme_org_emergency_org_cache_url

        assert_response :success
      end

      test "PATCH/PUT update returns no_content for all emergency cache controllers" do
        patch zenith.acme_org_emergency_app_cache_url

        assert_response :no_content

        put zenith.acme_org_emergency_app_cache_url

        assert_response :no_content

        patch zenith.acme_org_emergency_com_cache_url

        assert_response :no_content

        put zenith.acme_org_emergency_com_cache_url

        assert_response :no_content

        patch zenith.acme_org_emergency_org_cache_url

        assert_response :no_content

        put zenith.acme_org_emergency_org_cache_url

        assert_response :no_content
      end

      test "DELETE destroy returns no_content for all emergency cache controllers" do
        delete zenith.acme_org_emergency_app_cache_url

        assert_response :no_content

        delete zenith.acme_org_emergency_com_cache_url

        assert_response :no_content

        delete zenith.acme_org_emergency_org_cache_url

        assert_response :no_content
      end
    end
  end
end
