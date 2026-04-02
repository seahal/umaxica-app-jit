# typed: false
# frozen_string_literal: true

require "test_helper"

module Main
  module Org
    class SitemapsControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("MAIN_STAFF_URL", "main.org.localhost")
      end

      test "should get sitemap xml" do
        get main_org_sitemap_url

        assert_response :success
        assert_equal "application/xml; charset=utf-8", response.content_type
      end
    end
  end
end
