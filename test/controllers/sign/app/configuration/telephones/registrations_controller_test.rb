# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::Telephones::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_telephone_statuses
  include ActiveJob::TestHelper

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @token = UserToken.create!(
      user_id: @user.id,
    )
  end

  teardown do
    # Cleanup if needed
  end

  def request_headers
    {
      "Host" => @host,
      "X-TEST-CURRENT-USER" => @user.id,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }
  end

  test "create registers telephone for current user" do
    assert_enqueued_jobs 1, only: SmsDeliveryJob do
      assert_difference("UserTelephone.count", 1) do
        post sign_app_configuration_telephones_registration_url(ri: "jp"),
             params: { user_telephone: { raw_number: "+10000000009" } },
             headers: request_headers
      end
    end

    assert_response :redirect
    assert_redirected_to edit_sign_app_configuration_telephones_registration_url(ri: "jp")

    user_telephone = UserTelephone.order(created_at: :desc).first
    assert_equal @user.id, user_telephone.user_id
    assert_equal UserTelephoneStatus::UNVERIFIED, user_telephone.user_telephone_status_id
    assert_equal 0, UserTelephone.where(user_id: 0).count
    job = enqueued_jobs.last
    assert_equal SmsDeliveryJob, job[:job]
    assert_equal "+10000000009", job[:args].first["to"]
  end
end
