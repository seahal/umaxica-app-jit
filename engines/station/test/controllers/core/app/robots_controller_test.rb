# typed: false
# frozen_string_literal: true

require "test_helper"

module Core
  module App
    class RobotsControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("MAIN_SERVICE_URL", "main.app.localhost")
      end

      test "GET /robots.txt returns plain text robots content" do
        get main_app_robots_path

        assert_response :success
        assert_match(/text\/plain/, response.media_type)
        assert_includes response.body, "Allow: /"
        assert_includes response.body, "Disallow: /configuration"
        assert_includes response.body, "Disallow: /edge"
        assert_includes response.body, "Disallow: /web"
      end

      test "GET /robots.txt sets CDN cache headers" do
        get main_app_robots_path

        assert_response :success
        assert_includes response.headers["Cache-Control"], "public"
        assert_includes response.headers["Cache-Control"], "max-age=3600"
        assert_includes response.headers["Cache-Control"], "s-maxage=86400"
      end
    end
  end
end
