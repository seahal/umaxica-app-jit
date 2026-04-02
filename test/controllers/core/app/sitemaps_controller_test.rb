# typed: false
# frozen_string_literal: true

require "test_helper"

module Main
  module App
    class SitemapsControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("MAIN_SERVICE_URL", "main.app.localhost")
      end

      test "should get sitemap xml" do
        get main_app_sitemap_url

        assert_response :success
        assert_equal "application/xml; charset=utf-8", response.content_type
      end
    end
  end
end
