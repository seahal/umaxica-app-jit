require "test_helper"

module Api
  module App
    module V1
      module Inquiry
        class ValidTelephoneNumbersControllerTest < ActionDispatch::IntegrationTest
          # FIXME: change to run
          test "should get show" do
            get api_app_v1_inquiry_valid_telephone_number_url "KzgxMDAwMDAw"
            assert_equal "application/json", @response.media_type
            assert @response.body.to_json["valid"]
            assert_response :success
          end

          # FIXME: change to run only json files
          test "should get show invalid telephone number" do
            get api_app_v1_inquiry_valid_email_address_url "KzgxMDAwMDAw"
            assert_equal "application/json", @response.media_type
            assert @response.body.to_json["valid"]
            assert_response :success
          end
        end
      end
    end
  end
end
