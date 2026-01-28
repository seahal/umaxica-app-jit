# frozen_string_literal: true

require "test_helper"

module Sign
  module Org
    module Client
      module V1
        class HealthsControllerTest < ActionDispatch::IntegrationTest
          test "returns success for json format" do
            get sign_org_client_v1_health_url(format: :json, ri: "jp")

            assert_response :success
            assert_equal "OK", response.parsed_body["status"]
          end
        end
      end
    end
  end
end
