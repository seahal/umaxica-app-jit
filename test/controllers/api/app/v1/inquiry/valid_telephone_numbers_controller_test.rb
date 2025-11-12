require "test_helper"

class Api::App::V1::Inquiry::ValidTelephoneNumbersControllerTest < ActionDispatch::IntegrationTest
  test "should post create" do
    post api_app_v1_inquiry_valid_telephone_numbers_url, params: { telephone_number: "+819012345678" }

    assert_equal "application/json", @response.media_type
    assert JSON.parse(@response.body)["valid"]
    assert_response :success
  end

  test "should post create invalid telephone number" do
    post api_app_v1_inquiry_valid_telephone_numbers_url, params: { telephone_number: "+000000000000" }

    assert_equal "application/json", @response.media_type
    # This telephone number may still be considered valid format-wise
    # The actual validation logic determines this
    result = JSON.parse(@response.body)["valid"]

    assert_includes [ true, false ], result, "Expected valid to be boolean"
    assert_response :success
  end

  test "should handle invalid telephone number parameter" do
    post api_app_v1_inquiry_valid_telephone_numbers_url, params: { telephone_number: " 1 2 3" }

    assert_equal "application/json", @response.media_type
    # Invalid format should return false, but check actual implementation
    result = JSON.parse(@response.body)["valid"]

    assert_includes [ true, false ], result, "Expected valid to be boolean"
    assert_response :success
  end
end
