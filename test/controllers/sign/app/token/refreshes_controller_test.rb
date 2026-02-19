# frozen_string_literal: true

require "test_helper"

class Sign::App::Token::RefreshesControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_tokens, :user_token_statuses

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @user.update!(status_id: UserStatus::ACTIVE)
    @token = UserToken.create!(user: @user, status: UserToken::STATUS_ACTIVE)
    @refresh_token = @token.rotate_refresh_token!
  end

  test "create with valid refresh token returns new access token" do
    post sign_app_edge_v1_token_refresh_path, params: { refresh_token: @refresh_token }

    assert_response :ok
    json = response.parsed_body
    assert json["refreshed"]
    # Access token should be in cookies
    assert_not_nil cookies[::Auth::Base::ACCESS_COOKIE_KEY]
  end

  test "create with refresh token from cookie" do
    cookies[::Auth::Base::REFRESH_COOKIE_KEY] = @refresh_token

    post sign_app_edge_v1_token_refresh_path

    assert_response :ok
    json = response.parsed_body
    assert json["refreshed"]
  end

  test "create with missing refresh token returns bad_request" do
    post sign_app_edge_v1_token_refresh_path

    assert_response :bad_request
    json = response.parsed_body
    assert_equal "missing_refresh_token", json["error_code"]
    assert_equal I18n.t("sign.token_refresh.errors.missing_refresh_token"), json["error"]
  end

  test "create with invalid refresh token returns unauthorized" do
    post sign_app_edge_v1_token_refresh_path, params: { refresh_token: "invalid_token" }

    assert_response :unauthorized
    json = response.parsed_body
    assert_equal "invalid_refresh_token", json["error_code"]
  end

  test "create with expired refresh token returns unauthorized" do
    @token.update!(refresh_expires_at: 1.day.ago)

    post sign_app_edge_v1_token_refresh_path, params: { refresh_token: @refresh_token }

    assert_response :unauthorized
    json = response.parsed_body
    # Differentiates as invalid_refresh_token in rotate_refresh! if expired
    assert_equal "invalid_refresh_token", json["error_code"]
  end

  test "create with revoked token returns unauthorized" do
    @token.update!(revoked_at: Time.current)

    post sign_app_edge_v1_token_refresh_path, params: { refresh_token: @refresh_token }

    assert_response :unauthorized
    json = response.parsed_body
    assert_equal "invalid_refresh_token", json["error_code"]
  end

  test "create with restricted session returns conflict" do
    @token.update!(status: UserToken::STATUS_RESTRICTED)

    post sign_app_edge_v1_token_refresh_path, params: { refresh_token: @refresh_token }

    assert_response :forbidden
    json = response.parsed_body
    assert_equal "restricted_session", json["error_code"]
    assert_equal "きんそくじこうです", json["error"]
  end

  test "sets cache-control header to no-store" do
    post sign_app_edge_v1_token_refresh_path, params: { refresh_token: @refresh_token }

    assert_equal "no-store", response.headers["Cache-Control"]
  end

  test "emits event on validation failure" do
    events = []
    subscriber = Object.new
    subscriber.define_singleton_method(:emit) do |event|
      events << [event[:name], event[:payload]]
    end

    # The event name is user.token.refresh.failed
    Rails.event.subscribe(subscriber) { |event| event[:name] == "user.token.refresh.failed" }

    begin
      # Provide an invalid token to trigger the failed event
      post sign_app_edge_v1_token_refresh_path, params: { refresh_token: "invalid_token" }

      assert_equal 1, events.length
      assert_equal "Sign::InvalidRefreshToken", events[0][1][:reason]
    ensure
      Rails.event.unsubscribe(subscriber)
    end
  end
end
