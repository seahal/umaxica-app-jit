# typed: false
# frozen_string_literal: true

    require "test_helper"

    class BaseRoutingIntegrityTest < ActionDispatch::IntegrationTest
      test "core app root route exists" do
        assert_generates "/", { controller: "base/app/roots", action: "index" }
      end

      test "core app health route exists" do
        assert_generates "/health", { controller: "base/app/healths", action: "show" }
      end

      test "core app sitemap route exists" do
        assert_generates "/sitemap.xml", { controller: "base/app/sitemaps", action: "show" }
      end

      test "core com root route exists" do
        assert_generates "/", { controller: "base/com/roots", action: "index" }
      end

      test "core org root route exists" do
        assert_generates "/", { controller: "base/org/roots", action: "index" }
      end

      test "url helpers are defined for core routes" do
        assert_respond_to self, :base_app_root_url
        assert_respond_to self, :base_com_root_url
        assert_respond_to self, :base_org_root_url
        assert_respond_to self, :base_app_health_url
        assert_respond_to self, :base_com_health_url
        assert_respond_to self, :base_org_health_url
        assert_respond_to self, :base_app_sitemap_url
        assert_respond_to self, :base_com_sitemap_url
        assert_respond_to self, :base_org_sitemap_url
      end

      test "edge v0 routes are properly namespaced" do
        assert_generates "/edge/v0/health", { controller: "base/app/edge/v0/healths", action: "show" }
        assert_generates "/edge/v0/sitemap", { controller: "base/app/edge/v0/sitemaps", action: "show" }
      end

      test "web v0 routes are properly namespaced" do
        assert_generates "/web/v0/cookie", { controller: "base/app/web/v0/cookies", action: "show" }
        assert_generates "/web/v0/theme", { controller: "base/app/web/v0/themes", action: "show" }
      end
    end
  end
end
