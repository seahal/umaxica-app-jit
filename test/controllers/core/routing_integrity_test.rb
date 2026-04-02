# typed: false
# frozen_string_literal: true

require "test_helper"

# This test verifies routing integrity for core domain
# After refactoring (e.g., core -> main), run this to ensure all routes still work
class CoreRoutingIntegrityTest < ActionDispatch::IntegrationTest
  test "core app root route exists" do
    host! ENV.fetch("MAIN_SERVICE_URL", "main.app.localhost")

    assert_recognizes({ controller: "core/app/roots", action: "index" }, "/")
  end

  test "core app health route exists" do
    host! ENV.fetch("MAIN_SERVICE_URL", "main.app.localhost")

    assert_recognizes({ controller: "core/app/healths", action: "show" }, "/health")
  end

  test "core app sitemap route exists" do
    host! ENV.fetch("MAIN_SERVICE_URL", "main.app.localhost")

    assert_recognizes({ controller: "core/app/sitemaps", action: "show" }, "/sitemap")
  end

  test "core com root route exists" do
    host! ENV.fetch("MAIN_CORPORATE_URL", "main.com.localhost")

    assert_recognizes({ controller: "core/com/roots", action: "index" }, "/")
  end

  test "core org root route exists" do
    host! ENV.fetch("MAIN_STAFF_URL", "main.org.localhost")

    assert_recognizes({ controller: "core/org/roots", action: "index" }, "/")
  end

  test "url helpers are defined for core routes" do
    # Verify that URL helpers are available after any refactoring
    assert_respond_to self, :main_app_root_url
    assert_respond_to self, :main_com_root_url
    assert_respond_to self, :main_org_root_url
    assert_respond_to self, :main_app_health_url
    assert_respond_to self, :main_com_health_url
    assert_respond_to self, :main_org_health_url
    assert_respond_to self, :main_app_sitemap_url
    assert_respond_to self, :main_com_sitemap_url
    assert_respond_to self, :main_org_sitemap_url
  end

  test "edge v0 routes are properly namespaced" do
    host! ENV.fetch("MAIN_SERVICE_URL", "main.app.localhost")

    # Edge routes should be under /edge/v0 namespace
    assert_recognizes(
      {
        controller: "core/app/edge/v0/healths",
        action: "show",
      }, "/edge/v0/health",
    )

    assert_recognizes(
      {
        controller: "core/app/edge/v0/sitemaps",
        action: "show",
      }, "/edge/v0/sitemap",
    )
  end

  test "web v0 routes are properly namespaced" do
    host! ENV.fetch("MAIN_SERVICE_URL", "main.app.localhost")

    assert_recognizes(
      {
        controller: "core/app/web/v0/cookies",
        action: "show",
      }, "/web/v0/cookie",
    )

    assert_recognizes(
      {
        controller: "core/app/web/v0/themes",
        action: "show",
      }, "/web/v0/theme",
    )
  end
end
