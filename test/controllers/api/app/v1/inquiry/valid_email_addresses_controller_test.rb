require "test_helper"

class Api::App::V1::Inquiry::ValidEmailAddressControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get api_app_v1_inquiry_valid_email_address_url Base64.urlsafe_encode64("one@example.com")

    assert_equal "application/json", @response.media_type
    assert JSON.parse(@response.body)["valid"]
    assert_response :ok
  end

  test "should get show " do
    get api_app_v1_inquiry_valid_email_address_url Base64.urlsafe_encode64("a")

    body = JSON.parse(@response.body)

    assert_kind_of Array, body["errors"], "Errors should be an array"
    assert_response :unprocessable_entity
  end

  test "should not get invalid data" do
    assert_raises(ArgumentError) do
      get api_app_v1_inquiry_valid_email_address_url " 1 2 3"
    end
  end
end
