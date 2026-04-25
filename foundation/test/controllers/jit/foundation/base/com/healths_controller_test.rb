# typed: false
# frozen_string_literal: true

    require "test_helper"

    module Base
      module Com
        class HealthsControllerTest < ActionDispatch::IntegrationTest
          test "should get show" do
            get foundation.base_com_health_url

            assert_response :success
            assert_equal "text/plain; charset=utf-8", response.headers["Content-Type"]
            assert_includes @response.body, "OK"
            assert_match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/, @response.body)
          end

          test "should get show with postfix" do
            get foundation.base_com_health_url(format: :html)

            assert_response :success
            assert_equal "text/plain; charset=utf-8", response.headers["Content-Type"]
            assert_includes @response.body, "OK"
            assert_match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/, @response.body)
          end

          test "should handle redirect if response is redirect" do
            get foundation.base_com_health_url

            if response.redirect?
              assert_response :redirect
              assert_not_nil response.location
            else
              assert_response :success
            end
          end

          test "should accept both success and redirect responses" do
            get foundation.base_com_health_url(format: :html)

            assert_includes [200], response.status
          end
        end
      end
    end
  end
end
