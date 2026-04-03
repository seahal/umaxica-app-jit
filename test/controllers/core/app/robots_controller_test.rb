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
        assert_match(/User-agent/, response.body)
      end
    end
  end
end
