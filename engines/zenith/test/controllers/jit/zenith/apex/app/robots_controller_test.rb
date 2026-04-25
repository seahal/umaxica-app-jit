# typed: false
# frozen_string_literal: true

module Jit
  module Zenith
    require "test_helper"

    module Acme
      module App
        class RobotsControllerTest < ActionDispatch::IntegrationTest
          setup do
            host! ENV.fetch("ZENITH_ACME_APP_URL", "app.localhost")
          end

          test "GET /robots.txt returns plain text robots content" do
            get zenith.acme_app_robots_url(ri: "jp")

            assert_response :success
            assert_match(/text\/plain/, response.media_type)
            assert_match(/User-agent/, response.body)
          end
        end
      end
    end
  end
end
