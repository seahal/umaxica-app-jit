# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    require "test_helper"

    module Main
      module App
        class SitemapsControllerTest < ActionDispatch::IntegrationTest
          setup do
            host! ENV.fetch("FOUNDATION_BASE_APP_URL", "base.app.localhost")
          end

          test "should get sitemap xml" do
            get foundation.base_app_sitemap_url

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
  end
end
