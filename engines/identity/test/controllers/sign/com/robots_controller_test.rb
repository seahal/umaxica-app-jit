# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    require "test_helper"

    module Sign
      module Com
        class RobotsControllerTest < ActionDispatch::IntegrationTest
          setup do
            host! ENV.fetch("IDENTITY_SIGN_COM_URL", "sign.com.localhost")
          end

          test "GET /robots.txt returns plain text robots content" do
            get sign_com_robots_url(ri: "jp")

            assert_response :success
            assert_match(/text\/plain/, response.media_type)
            assert_match(/User-agent/, response.body)
          end
        end
      end
    end
  end
end
