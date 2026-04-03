# typed: false
# frozen_string_literal: true

require "test_helper"

module Apex
  module App
    class SitemapsControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("APEX_SERVICE_URL", "app.localhost")
      end

      test "GET /sitemap.xml returns XML sitemap" do
        get apex_app_sitemap_url(ri: "jp")

        assert_response :success
        assert_match(/application\/xml/, response.media_type)
        assert_match(/xml/, response.body)
      end

      test "GET /sitemap.xml sets cache headers" do
        get apex_app_sitemap_url(ri: "jp")

        assert_response :success
        assert_match(/max-age=/, response.headers["Cache-Control"])
      end
    end
  end
end
