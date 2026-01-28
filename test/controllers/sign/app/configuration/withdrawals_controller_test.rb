# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    @user = users(:one)
  end

  def request_headers
    { "Host" => @host }
  end

  test "should get new withdrawal page" do
    get new_sign_app_configuration_withdrawal_url(ri: "jp"),
        headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

    assert_response :success
  end

  test "create requests withdrawal and sets timestamps" do
    travel_to Time.zone.parse("2026-01-24 12:00:00") do
      post sign_app_configuration_withdrawal_url(ri: "jp"),
           headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

      @user.reload
      assert_equal UserStatus::PRE_WITHDRAWAL_CONDITION, @user.status_id
      assert_equal Time.current, @user.withdraw_requested_at
      assert_equal 31.days.from_now, @user.withdraw_scheduled_at
      assert_equal 24.hours.from_now, @user.withdraw_cooldown_until
    end
  end

  test "update requests withdrawal and sets timestamps" do
    travel_to Time.zone.parse("2026-01-24 12:00:00") do
      patch sign_app_configuration_withdrawal_url(ri: "jp"),
            headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

      @user.reload
      assert_equal UserStatus::PRE_WITHDRAWAL_CONDITION, @user.status_id
      assert_equal Time.current, @user.withdraw_requested_at
      assert_equal 31.days.from_now, @user.withdraw_scheduled_at
      assert_equal 24.hours.from_now, @user.withdraw_cooldown_until
    end
  end

  test "destroy finalizes withdrawal and revokes sessions" do
    @user.update!(
      status_id: UserStatus::PRE_WITHDRAWAL_CONDITION,
      withdraw_requested_at: 2.days.ago,
      withdraw_scheduled_at: 29.days.from_now,
      withdraw_cooldown_until: 1.hour.ago,
    )
    token = UserToken.create!(user: @user)
    assert_nil token.revoked_at

    delete sign_app_configuration_withdrawal_url(ri: "jp"),
           headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

    @user.reload
    token.reload
    assert_equal UserStatus::PRE_WITHDRAWAL_CONDITION, @user.status_id
    assert_not_nil token.revoked_at
  end
end
