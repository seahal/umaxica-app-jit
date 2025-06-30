require "test_helper"

module Api
  module App
    module V1
      module Inquiry
        class EmailAddressControllerTest < ActionDispatch::IntegrationTest
          # FIXME: change to run only json files
          test "should get show" do
            get api_app_v1_inquiry_email_address_url "ZXhhbXBsZUBleGFtcGxlLmNvbQ=="
            assert_equal "application/json", @response.media_type
            assert @response.body.to_json["valid"]
            assert_response :success
          end

          # FIXME: change to run only json files
          # test "should get show invalid email address" do
          #   get api_app_v1_inquiry_email_address_url 0
          #   assert_equal "application/json", @response.media_type
          #   assert @response.body.to_json['valid']
          #   assert_response :success
          # end
        end
      end
    end
  end
end
