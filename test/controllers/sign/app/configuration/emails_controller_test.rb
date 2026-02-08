# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::EmailsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_token_statuses, :user_token_kinds, :user_email_statuses

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @token = UserToken.create!(
      user_id: @user.id,
      last_step_up_at: 1.minute.ago,
      last_step_up_scope: "configuration_email",
    )
  end

  def request_headers
    {
      "Host" => @host,
      "X-TEST-CURRENT-USER" => @user.id,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }
  end

  test "should get index" do
    get sign_app_configuration_emails_url(ri: "jp"), headers: request_headers
    assert_response :success
  end

  test "index displays verified status" do
    email = UserEmail.create!(
      address: "verified@example.com",
      user: @user,
      user_email_status_id: UserEmailStatus::VERIFIED,
    )

    get sign_app_configuration_emails_url(ri: "jp"), headers: request_headers

    assert_response :success
    assert_includes @response.body, "認証済み"
    assert_includes @response.body, email.address
  end

  test "destroy removes email when not last method" do
    email1 = UserEmail.create!(
      address: "delete1@example.com",
      user: @user,
      user_email_status_id: UserEmailStatus::VERIFIED,
    )
    UserEmail.create!(
      address: "delete2@example.com",
      user: @user,
      user_email_status_id: UserEmailStatus::VERIFIED,
    )

    assert_difference("UserEmail.count", -1) do
      delete sign_app_configuration_email_url(email1, ri: "jp"), headers: request_headers
    end

    assert_response :see_other
  end
end
