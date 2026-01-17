# frozen_string_literal: true

require "test_helper"

class Sign::Org::Edge::V1::Token::ChecksControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_tokens

  setup do
    @staff = staffs(:one)
    @host = ENV.fetch("SIGN_STAFF_URL", "test.umaxica.com")
  end

  test "GET check with valid JWT access token returns 200" do
    token_record = StaffToken.create!(staff: @staff)
    token_record.rotate_refresh_token!

    access_token = jwt_access_token_for(
      @staff,
      host: @host,
      session_public_id: token_record.public_id,
      resource_type: "staff",
    )

    cookies[Auth::Base::ACCESS_COOKIE_KEY] = access_token

    get "/edge/v1/token/check",
        headers: { "Host" => @host, "Accept" => "application/json" },
        as: :json

    assert_response :ok
    json = response.parsed_body
    assert json["authenticated"], "Staff should be authenticated"
  end

  test "GET check without access token returns 401" do
    get "/edge/v1/token/check",
        headers: { "Host" => @host, "Accept" => "application/json" },
        as: :json

    assert_response :unauthorized
    json = response.parsed_body
    assert_not json["authenticated"]
  end
end
