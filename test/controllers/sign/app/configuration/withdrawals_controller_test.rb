# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  fixtures :users, :user_statuses, :user_token_kinds, :user_token_statuses

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    host! @host
    @user = users(:one)
    @headers = as_user_headers(@user, host: @host)
  end

  test "new requires schedule confirmation to proceed" do
    get new_sign_app_configuration_withdrawal_url(ri: "jp"), headers: @headers
    assert_response :success

    get new_sign_app_configuration_withdrawal_url(ri: "jp", ack_schedule_purge: "0"), headers: @headers
    assert_response :unprocessable_content

    get new_sign_app_configuration_withdrawal_url(ri: "jp", ack_schedule_purge: "1"), headers: @headers
    assert_response :success
    assert_select "label", text: I18n.t("sign.app.configuration.withdrawal.deactivate.ack_label")
  end

  test "update requires deactivate confirmation" do
    patch sign_app_configuration_withdrawal_url(ri: "jp"),
          params: { ack_deactivate_today: "0" },
          headers: @headers

    assert_response :unprocessable_content
    assert_nil @user.reload.deactivated_at
  end

  test "update sets deactivation timestamps" do
    travel_to Time.zone.parse("2026-02-09 10:00:00") do
      patch sign_app_configuration_withdrawal_url(ri: "jp"),
            params: { ack_deactivate_today: "1" },
            headers: @headers
    end

    assert_response :see_other
    assert_redirected_to edit_sign_app_configuration_path(ri: "jp")

    @user.reload
    assert_not_nil @user.withdrawal_started_at
    assert_not_nil @user.deactivated_at
    assert_not_nil @user.scheduled_purge_at
    assert_equal @user.deactivated_at + 31.days, @user.scheduled_purge_at
  end
end
