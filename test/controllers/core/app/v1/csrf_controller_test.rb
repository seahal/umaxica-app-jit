# frozen_string_literal: true

require "test_helper"

module Core
  module App
    module V1
      class CsrfControllerTest < ActionDispatch::IntegrationTest
        test "returns csrf token payload" do
          get core_app_v1_csrf_url

          assert_response :success
          assert_not response.parsed_body["csrf_token"].to_s.empty?
        end
      end
    end
  end
end
