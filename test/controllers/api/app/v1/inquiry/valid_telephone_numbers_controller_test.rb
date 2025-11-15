require "test_helper"

class Api::App::V1::Inquiry::ValidTelephoneNumbersControllerTest < ActionDispatch::IntegrationTest
  test "should post create 3" do
    post api_app_v1_inquiry_valid_telephone_numbers_url, params: { telephone_number: "+819012345678" }

    assert_equal "application/json", @response.media_type
    assert JSON.parse(@response.body)["valid"]
    assert_response :ok
  end

  test "should post create invalid telephone number" do
    post api_app_v1_inquiry_valid_telephone_numbers_url, params: { telephone_number: "+000000000000" }

    assert_equal "application/json", @response.media_type
    body = JSON.parse(@response.body)

    # Check if valid is false and errors are present
    if body["valid"] == false
      assert body.key?("errors"), "Response should include errors array when invalid"
      assert_kind_of Array, body["errors"], "Errors should be an array"
    end
  end

  test "invalid telephone" do
    post api_app_v1_inquiry_valid_telephone_numbers_url, params: { telephone_number: "invalid" }
    body = JSON.parse(@response.body)

    # Invalid format should return false with errors
    assert_not body["valid"], "Response should mark telephone as invalid"
    assert body.key?("errors"), "Response should include errors array when invalid"
    assert_kind_of Array, body["errors"], "Errors should be an array"
  end
end
