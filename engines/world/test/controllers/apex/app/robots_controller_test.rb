# typed: false
# frozen_string_literal: true

require "test_helper"

module Apex
  module App
    class RobotsControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("APEX_SERVICE_URL", "app.localhost")
      end

      test "GET /robots.txt returns plain text robots content" do
        get apex_app_robots_url(ri: "jp")

        assert_response :success
        assert_match(/text\/plain/, response.media_type)
        assert_match(/User-agent/, response.body)
      end
    end
  end
end
