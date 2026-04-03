# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  module App
    class RobotsControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
      end

      test "GET /robots.txt returns plain text robots content" do
        get sign_app_robots_url(ri: "jp")

        assert_response :success
        assert_match(/text\/plain/, response.media_type)
        assert_match(/User-agent/, response.body)
      end
    end
  end
end
