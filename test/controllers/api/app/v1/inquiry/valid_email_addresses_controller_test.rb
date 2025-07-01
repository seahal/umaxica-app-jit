require "test_helper"

module Api
  module App
    module V1
      module Inquiry
        class ValidEmailAddressControllerTest < ActionDispatch::IntegrationTest
          test "should get show" do
            get api_app_v1_inquiry_valid_email_address_url Base64.urlsafe_encode64("one@example.com")
            assert_equal "application/json", @response.media_type
            assert JSON.parse(@response.body)["valid"]
            assert_response :success
          end

          test "should get show invalid email address" do
            get api_app_v1_inquiry_valid_email_address_url Base64.urlsafe_encode64("a")
            assert_not JSON.parse(@response.body)["valid"]
            assert_response :success
          end

          test "should not get invalid data" do
            assert_raise do
              get api_app_v1_inquiry_valid_email_address_url " 1 2 3"
            end
          end
        end
      end
    end
  end
end
