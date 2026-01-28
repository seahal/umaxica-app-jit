require "test_helper"

class TelephoneConcurrencyTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    host! "sign.app.localhost"

    # Create missing statuses
    unless UserTelephoneStatus.exists?(id: "UNVERIFIED_WITH_SIGN_UP")
      UserTelephoneStatus.create!(id: "UNVERIFIED_WITH_SIGN_UP")
    end
    unless UserTelephoneStatus.exists?(id: "VERIFIED_WITH_SIGN_UP")
      UserTelephoneStatus.create!(id: "VERIFIED_WITH_SIGN_UP")
    end

    # Clean up existing telephones to start fresh
    UserTelephone.delete_all
  end

  test "multiple unverified telephones block registration due to limit on dummy user" do
    # Create 4 unverified telephones (simulating other users or abandoned sessions)
    4.times do |i|
      ut = UserTelephone.new(
        number: "+1555000000#{i}",
        user_identity_telephone_status_id: "UNVERIFIED_WITH_SIGN_UP",
        otp_attempts_count: 0,
        otp_counter: "0",
        otp_private_key: "secret"
      )
      # Force the dummy ID if it's not set automatically (it is by before_validation)
      ut.save!
    end

    assert_equal 4, UserTelephone.where(user_id: "00000000-0000-0000-0000-000000000000").count

    # Try to register a new one
    headers = { "X-TEST-CURRENT-USER" => @user.id }
    post sign_app_configuration_telephones_path(ri: "jp"),
         headers: headers,
         params: { user_telephone: { telephone_number: "09012345678" } }

    # This should succeed now
    assert_response :redirect
    follow_redirect!(headers: headers)
    assert_response :success
  end
end
