# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    require "test_helper"

    module Main
      module Org
        class SitemapsControllerTest < ActionDispatch::IntegrationTest
          setup do
            host! ENV.fetch("FOUNDATION_BASE_ORG_URL", "base.org.localhost")
          end

          test "should get sitemap xml" do
            get foundation.base_org_sitemap_url

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
