# typed: false
# frozen_string_literal: true

require "test_helper"

module Docs
  module App
    class SitemapsControllerTest < ActionDispatch::IntegrationTest
      setup do
        https!
        host! ENV.fetch("DOCS_SERVICE_URL", "docs.app.localhost")
      end

      test "GET /sitemap.xml returns XML sitemap" do
        get "/sitemap.xml"

        assert_response :success
        assert_match(/application\/xml/, response.media_type)
        assert_match(/xml/, response.body)
      end

      test "GET /sitemap.xml sets cache headers" do
        get "/sitemap.xml"

        assert_response :success
        assert_match(/max-age=/, response.headers["Cache-Control"])
      end
    end
  end
end
