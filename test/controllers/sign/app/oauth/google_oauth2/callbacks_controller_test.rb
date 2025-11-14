require "test_helper"

module Sign
  module App
    module Oauth
      module GoogleOauth2
        class CallbacksControllerTest < ActionDispatch::IntegrationTest
          def host
            ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
          end

          test "should handle OAuth callback" do
            skip "Full callback tests with database writes are skipped due to readonly mode in test environment"
          end

          test "should handle OAuth callback with origin" do
            skip "Full callback tests with database writes are skipped due to readonly mode in test environment"
          end
        end
      end
    end
  end
end
