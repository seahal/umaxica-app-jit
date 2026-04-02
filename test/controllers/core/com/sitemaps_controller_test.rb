# typed: false
# frozen_string_literal: true

require "test_helper"

module Main
  module Com
    class SitemapsControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("MAIN_CORPORATE_URL", "main.com.localhost")
      end

      test "should get sitemap xml" do
        get main_com_sitemap_url

        assert_response :success
        assert_equal "application/xml; charset=utf-8", response.content_type
        assert_includes response.headers["Cache-Control"], "public"
        assert_includes response.headers["Cache-Control"], "max-age=300"
        assert_includes response.headers["Cache-Control"], "s-maxage=600"
        assert_equal "max-age=600", response.headers["Surrogate-Control"]
      end
    end
  end
end
