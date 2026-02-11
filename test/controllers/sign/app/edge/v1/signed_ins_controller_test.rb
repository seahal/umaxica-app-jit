# frozen_string_literal: true

require "test_helper"

class Sign::App::Edge::V1::SignedInsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @user = users(:one)
    @host = ENV.fetch("SIGN_SERVICE_URL", "test.umaxica.com")
    UserToken.where(user: @user).delete_all
  end

  test "GET signed_in with valid access token returns signed_in true" do
    token_record = UserToken.create!(user: @user)
    token_record.rotate_refresh_token!
    access_token = jwt_access_token_for(
      @user,
      host: @host,
      session_public_id: token_record.public_id,
      resource_type: "user",
    )
    cookies[Auth::Base::ACCESS_COOKIE_KEY] = access_token

    get "/edge/v1/signed_in",
        headers: { "Host" => @host, "Accept" => "application/json" },
        as: :json

    assert_response :ok
    assert_equal({ "signed_in" => true }, response.parsed_body)
    assert_equal "no-store", response.headers["Cache-Control"]
  end

  test "GET signed_in refreshes access and returns signed_in true when refresh is valid" do
    token_record = UserToken.create!(user: @user)
    refresh_plain = token_record.rotate_refresh_token!
    cookies[Auth::Base::ACCESS_COOKIE_KEY] = "invalid.jwt.token"
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    get "/edge/v1/signed_in",
        headers: { "Host" => @host, "Accept" => "application/json" },
        as: :json

    assert_response :ok
    assert_equal({ "signed_in" => true }, response.parsed_body)
    assert response_has_cookie?(Auth::Base::ACCESS_COOKIE_KEY),
           "Response should set access cookie (#{Auth::Base::ACCESS_COOKIE_KEY})"
  end

  test "GET signed_in returns 401 when access and refresh are invalid" do
    cookies[Auth::Base::ACCESS_COOKIE_KEY] = "invalid.jwt.token"
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = "invalid.refresh.token"

    get "/edge/v1/signed_in",
        headers: { "Host" => @host, "Accept" => "application/json" },
        as: :json

    assert_response :unauthorized
    assert_equal(
      { "signed_in" => false, "error" => "unauthorized" },
      response.parsed_body,
    )
  end

  test "GET signed_in returns 403 for deactivated user even when refresh token is valid" do
    @user.update!(deactivated_at: Time.current, withdrawal_started_at: 1.hour.ago, scheduled_purge_at: 31.days.from_now)

    token_record = UserToken.create!(user: @user)
    refresh_plain = token_record.rotate_refresh_token!
    cookies[Auth::Base::ACCESS_COOKIE_KEY] = "invalid.jwt.token"
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    get "/edge/v1/signed_in",
        headers: { "Host" => @host, "Accept" => "application/json" },
        as: :json

    assert_response :forbidden
    assert_equal({ "error" => "WITHDRAWAL_REQUIRED" }, response.parsed_body)
  end
end
