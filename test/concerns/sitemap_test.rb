# typed: false
# frozen_string_literal: true

require "test_helper"

class SitemapTest < ActiveSupport::TestCase
  class TestController
    include Sitemap

    def test_show_xml
      @rendered = { format: :xml }
    end

    def test_show_json
      result = show_json
      @rendered = { format: :json, data: result }
    end

    def test_sitemap_entry
      sitemap_entry(loc: "https://example.com", lastmod: Time.current, changefreq: "daily", priority: 0.8)
    end

    def rendered
      @rendered
    end
  end

  test "BROWSER_CACHE_TTL is 5 minutes" do
    assert_equal 5.minutes, Sitemap::BROWSER_CACHE_TTL
  end

  test "CDN_CACHE_TTL is 10 minutes" do
    assert_equal 10.minutes, Sitemap::CDN_CACHE_TTL
  end

  test "sitemap_urls returns empty array by default" do
    controller = TestController.new

    assert_equal [], controller.send(:sitemap_urls)
  end

  test "sitemap_entry builds hash with loc" do
    controller = TestController.new
    entry = controller.send(:sitemap_entry, loc: "https://example.com")

    assert_equal "https://example.com", entry[:loc]
  end

  test "sitemap_entry includes lastmod when provided" do
    controller = TestController.new
    lastmod = Time.current
    entry = controller.send(:sitemap_entry, loc: "https://example.com", lastmod: lastmod)

    assert_equal lastmod.iso8601, entry[:lastmod]
  end

  test "sitemap_entry includes changefreq when provided" do
    controller = TestController.new
    entry = controller.send(:sitemap_entry, loc: "https://example.com", changefreq: "daily")

    assert_equal "daily", entry[:changefreq]
  end

  test "sitemap_entry includes priority when provided" do
    controller = TestController.new
    entry = controller.send(:sitemap_entry, loc: "https://example.com", priority: 0.8)

    assert_in_delta(0.8, entry[:priority])
  end

  test "sitemap_entry omits optional fields when not provided" do
    controller = TestController.new
    entry = controller.send(:sitemap_entry, loc: "https://example.com")

    assert_not_includes entry.keys, :lastmod
    assert_not_includes entry.keys, :changefreq
    assert_not_includes entry.keys, :priority
  end
end
