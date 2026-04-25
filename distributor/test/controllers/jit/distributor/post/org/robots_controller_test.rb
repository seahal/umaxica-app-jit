# typed: false
# frozen_string_literal: true

    require "test_helper"

    module Post
      module Org
        class RobotsControllerTest < ActionDispatch::IntegrationTest
          setup do
            https!
            host! ENV.fetch("DISTRIBUTOR_POST_ORG_URL", "docs.org.localhost")
          end

          test "GET /robots.txt returns plain text robots content" do
            get "/robots.txt"

            assert_response :success
            assert_match(/text\/plain/, response.media_type)
            assert_match(/User-agent/, response.body)
          end
        end
      end
    end
  end
end
