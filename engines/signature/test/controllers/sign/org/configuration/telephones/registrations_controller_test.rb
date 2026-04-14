# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Org::Configuration::Telephones::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_statuses, :staff_telephone_statuses
  include ActiveJob::TestHelper

  setup do
    host! ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
    @token = StaffToken.create!(staff: @staff, status: StaffToken::STATUS_ACTIVE)
    satisfy_staff_verification(@token)
  end

  def request_headers
    {
      "Host" => @host,
      "HTTPS" => "on",
      "X-TEST-CURRENT-STAFF" => @staff.id,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }
  end

  test "create registers telephone for current staff" do
    assert_enqueued_jobs 1, only: SmsDeliveryJob do
      assert_difference("StaffTelephone.count", 1) do
        post sign_org_configuration_telephones_registration_url(ri: "jp"),
             params: { staff_telephone: { raw_number: "+10000000009" } },
             headers: request_headers
      end
    end

    assert_redirected_to edit_sign_org_configuration_telephones_registration_url(ri: "jp")
  end

  test "new renders with national autocomplete" do
    get new_sign_org_configuration_telephones_registration_url(ri: "jp"), headers: request_headers

    assert_response :success
    assert_select "input[autocomplete='tel-national'][name='staff_telephone[raw_number]']"
  end

  test "create returns 422 for invalid number" do
    assert_no_difference("StaffTelephone.count") do
      post sign_org_configuration_telephones_registration_url(ri: "jp"),
           params: { staff_telephone: { raw_number: "invalid-number" } },
           headers: request_headers
    end

    assert_response :unprocessable_content
  end

  test "edit redirects if no valid session" do
    get edit_sign_org_configuration_telephones_registration_url(ri: "jp"), headers: request_headers

    assert_redirected_to new_sign_org_configuration_telephones_registration_url(ri: "jp")
  end

  test "update successfully verifies telephone" do
    post sign_org_configuration_telephones_registration_url(ri: "jp"),
         params: { staff_telephone: { raw_number: "+19999999999" } },
         headers: request_headers

    tel = StaffTelephone.order(created_at: :desc).first
    code = ROTP::HOTP.new(tel.otp_private_key).at(tel.otp_counter.to_i)

    patch sign_org_configuration_telephones_registration_url(ri: "jp"),
          params: { staff_telephone: { pass_code: code } },
          headers: request_headers

    assert_redirected_to sign_org_configuration_telephones_url(ri: "jp")
  end
end
