require "test_helper"

class Api::App::V1::Inquiry::ValidTelephoneNumbersControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get api_app_v1_inquiry_valid_telephone_number_url Base64.urlsafe_encode64("+819012345678")
    assert_equal "application/json", @response.media_type
    assert JSON.parse(@response.body)["valid"]
    assert_response :success
  end

  test "should get show invalid telephone number" do
    get api_app_v1_inquiry_valid_telephone_number_url Base64.urlsafe_encode64("+000000000000")
    assert_equal "application/json", @response.media_type
    assert_not JSON.parse(@response.body)["valid"]
    assert_response :success
  end

  test "should not get invalid data" do
    assert_raise do
      get api_app_v1_inquiry_valid_telephone_number_url " 1 2 3"
    end
  end
end
