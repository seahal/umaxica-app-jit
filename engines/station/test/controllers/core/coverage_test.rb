# typed: false
# frozen_string_literal: true

require "test_helper"

class CoreCoverageTest < ActionDispatch::IntegrationTest
  setup do
    @app_host = ENV.fetch("MAIN_SERVICE_URL", "main.app.localhost")
    @com_host = ENV.fetch("MAIN_CORPORATE_URL", "main.com.localhost")
    @org_host = ENV.fetch("MAIN_STAFF_URL", "main.org.localhost")
  end

  test "core app robots responds" do
    host! @app_host

    get main_app_robots_path

    assert_response :success
    assert_match(/text\/plain/, response.media_type)
  end

  test "core com robots responds" do
    host! @com_host

    get main_com_robots_path

    assert_response :success
    assert_match(/text\/plain/, response.media_type)
  end

  test "core org robots responds" do
    host! @org_host

    get main_org_robots_path

    assert_response :success
    assert_match(/text\/plain/, response.media_type)
  end

  test "core app edge sitemap responds" do
    host! @app_host

    get main_app_edge_v0_sitemap_url

    assert_response :success
    assert_kind_of Array, response.parsed_body["urls"]
  end

  test "core com edge sitemap responds" do
    host! @com_host

    get main_com_edge_v0_sitemap_url

    assert_response :success
    assert_kind_of Array, response.parsed_body["urls"]
  end

  test "core org edge sitemap responds" do
    host! @org_host

    get main_org_edge_v0_sitemap_url

    assert_response :success
    assert_kind_of Array, response.parsed_body["urls"]
  end
end
