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
      end
    end
  end
end
