# typed: false
# frozen_string_literal: true

require "test_helper"

class IdentitySignPageTest < IdentityAcceptanceTestBase
  # test "should get root page" do
  #   get sign_app_root_path
  #
  #   assert_response :success
  #   assert_select "title", "Home | Sign App"
  # end

  test "should get health check" do
    get sign_app_health_path

    assert_response :success
    assert_includes response.body, "OK"
  end

  test "should get robots.txt" do
    get sign_app_robots_path

    assert_response :success
    assert_match "text/plain", response.content_type
  end

  test "should get sitemap.xml" do
    get sign_app_sitemap_path

    assert_response :success
    assert_match "application/xml", response.content_type
  end
end
