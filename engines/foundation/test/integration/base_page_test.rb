# typed: false
# frozen_string_literal: true

require "test_helper"

class Foundation::BasePageTest < FoundationAcceptanceTestBase
  # test "should get contact page" do
  #   get foundation.new_base_app_contact_path
  #
  #   assert_response :success
  # end

  test "should get health check" do
    get foundation.base_app_health_path

    assert_response :success
    assert_includes response.body, "OK"
  end

  test "should get robots.txt" do
    get foundation.base_app_robots_path

    assert_response :success
    assert_match "text/plain", response.content_type
  end

  test "should get sitemap.xml" do
    get foundation.base_app_sitemap_path

    assert_response :success
    assert_match "application/xml", response.content_type
  end
end
