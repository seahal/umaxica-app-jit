# typed: false
# frozen_string_literal: true

require "test_helper"

class PublicRobotsRoutingTest < ActionDispatch::IntegrationTest
  test "acme surfaces define public file helpers" do
    assert_public_file_helpers(
      robots: %i(acme_com_robots_path acme_app_robots_path acme_org_robots_path),
      sitemap: %i(acme_com_sitemap_path acme_app_sitemap_path acme_org_sitemap_path),
    )
  end

  test "core surfaces define public file helpers" do
    assert_public_file_helpers(
      robots: %i(base_com_robots_path base_app_robots_path base_org_robots_path),
      sitemap: %i(base_com_sitemap_path base_app_sitemap_path base_org_sitemap_path),
    )
  end

  test "sign surfaces define public file helpers" do
    assert_public_file_helpers(
      robots: %i(sign_com_robots_path sign_app_robots_path sign_org_robots_path),
      sitemap: %i(sign_com_sitemap_path sign_app_sitemap_path sign_org_sitemap_path),
    )
  end

  test "docs surfaces define public file helpers" do
    assert_public_file_helpers(
      robots: %i(post_com_robots_path post_app_robots_path post_org_robots_path),
      sitemap: %i(post_com_sitemap_path post_app_sitemap_path post_org_sitemap_path),
    )
  end

  test "public file endpoints respond without redirect" do
    endpoints = [
      [method(:acme_com_robots_url), ENV["ZENITH_ACME_COM_URL"] || "com.localhost", "robots"],
      [method(:acme_app_robots_url), ENV["ZENITH_ACME_APP_URL"] || "app.localhost", "robots"],
      [method(:acme_org_robots_url), ENV["ZENITH_ACME_ORG_URL"] || "org.localhost", "robots"],
      [method(:sign_com_robots_url), ENV["IDENTITY_SIGN_COM_URL"] || "sign.com.localhost", "robots"],
      [method(:sign_app_robots_url), ENV["IDENTITY_SIGN_APP_URL"] || "sign.app.localhost", "robots"],
      [method(:sign_org_robots_url), ENV["IDENTITY_SIGN_ORG_URL"] || "sign.org.localhost", "robots"],
      [method(:acme_com_sitemap_url), ENV["ZENITH_ACME_COM_URL"] || "com.localhost", "sitemap"],
      [method(:acme_app_sitemap_url), ENV["ZENITH_ACME_APP_URL"] || "app.localhost", "sitemap"],
      [method(:acme_org_sitemap_url), ENV["ZENITH_ACME_ORG_URL"] || "org.localhost", "sitemap"],
      [method(:sign_com_sitemap_url), ENV["IDENTITY_SIGN_COM_URL"] || "sign.com.localhost", "sitemap"],
      [method(:sign_app_sitemap_url), ENV["IDENTITY_SIGN_APP_URL"] || "sign.app.localhost", "sitemap"],
      [method(:sign_org_sitemap_url), ENV["IDENTITY_SIGN_ORG_URL"] || "sign.org.localhost", "sitemap"],
    ]

    endpoints.each do |helper, host, kind|
      host! host
      get helper.call(ri: "jp"), headers: browser_headers

      assert_response :success
      assert_not_predicate response, :redirect?
      if kind == "robots"
        assert_equal "text/plain; charset=utf-8", response.content_type
        case host
        when /org\.localhost/, /sign\.org\.localhost/

          assert_equal <<~ROBOTS, response.body
            User-agent: *
            Allow: /
            Disallow: /auth
            Disallow: /configuration
            Disallow: /contacts
            Disallow: /edge
            Disallow: /emergency
            Disallow: /web
          ROBOTS
        when /app\.localhost/, /sign\.app\.localhost/

          assert_equal <<~ROBOTS, response.body
            User-agent: *
            Allow: /
            Disallow: /configuration
            Disallow: /contacts
            Disallow: /edge
            Disallow: /web
          ROBOTS
        else
          assert_equal "User-agent: *\nAllow: /\nDisallow:\n", response.body
        end
      else
        assert_equal "application/xml; charset=utf-8", response.content_type
      end
    end
  end

  private

  def assert_public_file_helpers(robots:, sitemap:)
    robots.each do |helper|
      assert_respond_to self, helper
      assert_equal "/robots.txt", public_send(helper)
    end

    sitemap.each do |helper|
      assert_respond_to self, helper
      assert_equal "/sitemap.xml", public_send(helper)
    end
  end
end
