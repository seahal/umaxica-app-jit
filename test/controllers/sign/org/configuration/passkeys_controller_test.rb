# frozen_string_literal: true

require "test_helper"

class Sign::Org::Configuration::PasskeysControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_statuses, :staff_passkey_statuses

  setup do
    host! ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
    @staff.update!(status_id: StaffStatus::ACTIVE)
    @token = StaffToken.create!(staff: @staff, status: StaffToken::STATUS_ACTIVE)
    @token.rotate_refresh_token!
    satisfy_staff_verification(@token)
    @host_headers = { "Host" => ENV["SIGN_STAFF_URL"] || "sign.org.localhost" }.freeze
    @headers = @host_headers.merge(
      "X-TEST-CURRENT-STAFF" => @staff.id.to_s,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    )
  end

  test "should get index" do
    get sign_org_configuration_passkeys_url(ri: "jp"), headers: @headers

    assert_response :success
    assert_select "h1", I18n.t("sign.org.configuration.passkeys.index.title")
  end

  test "should get show" do
    passkey = StaffPasskey.create!(
      staff: @staff,
      webauthn_id: "test_webauthn_id",
      external_id: "test_external_id",
      public_key: "test_public_key",
      name: "Test Passkey",
      status_id: StaffPasskeyStatus::ACTIVE,
    )

    get sign_org_configuration_passkey_url(passkey, ri: "jp"), headers: @headers

    assert_response :success
  end

  test "should get new" do
    get new_sign_org_configuration_passkey_url(ri: "jp"), headers: @headers

    assert_response :success
    assert_select "h1", I18n.t("sign.org.configuration.passkeys.new.page_title")
  end

  test "redirects unauthenticated staff to login" do
    get sign_org_configuration_passkeys_url(ri: "jp"), headers: @host_headers

    assert_response :redirect
    assert_match new_sign_org_in_path, response.headers["Location"]
  end

  test "should get edit" do
    passkey = StaffPasskey.create!(
      staff: @staff,
      webauthn_id: "test_webauthn_id_2",
      external_id: "test_external_id_2",
      public_key: "test_public_key_2",
      name: "Test Passkey",
      status_id: StaffPasskeyStatus::ACTIVE,
    )

    get edit_sign_org_configuration_passkey_url(passkey, ri: "jp"), headers: @headers

    assert_response :success
  end

  test "should patch update" do
    passkey = StaffPasskey.create!(
      staff: @staff,
      webauthn_id: "test_webauthn_id_3",
      external_id: "test_external_id_3",
      public_key: "test_public_key_3",
      name: "Old Name",
      status_id: StaffPasskeyStatus::ACTIVE,
    )

    patch sign_org_configuration_passkey_url(passkey, ri: "jp"),
          params: { staff_passkey: { description: "Updated Name" } },
          headers: @headers

    assert_redirected_to sign_org_configuration_passkey_path(passkey, ri: "jp")
    assert_equal "Updated Name", passkey.reload.description
  end

  test "update with invalid params renders edit" do
    passkey = StaffPasskey.create!(
      staff: @staff,
      webauthn_id: "test_webauthn_id_4",
      external_id: "test_external_id_4",
      public_key: "test_public_key_4",
      name: "Test Passkey",
      status_id: StaffPasskeyStatus::ACTIVE,
    )

    # Use any_instance to stub valid? on the instance loaded by the controller
    StaffPasskey.any_instance.stub(:valid?, false) do
      patch sign_org_configuration_passkey_url(passkey, ri: "jp"),
            params: { staff_passkey: { description: "" } },
            headers: @headers

      assert_response :unprocessable_content
    end
  end

  test "should delete destroy" do
    passkey = StaffPasskey.create!(
      staff: @staff,
      webauthn_id: "test_webauthn_id_5",
      external_id: "test_external_id_5",
      public_key: "test_public_key_5",
      name: "Test Passkey",
      status_id: StaffPasskeyStatus::ACTIVE,
    )

    assert_difference -> { StaffPasskey.count }, -1 do
      delete sign_org_configuration_passkey_url(passkey, ri: "jp"), headers: @headers
    end

    assert_redirected_to sign_org_configuration_passkeys_path(ri: "jp")
  end

  test "cannot access other staff's passkey" do
    other_staff = Staff.create!(status_id: StaffStatus::ACTIVE)
    other_passkey = StaffPasskey.create!(
      staff: other_staff,
      webauthn_id: "other_webauthn_id",
      external_id: "other_external_id",
      public_key: "other_public_key",
      name: "Other Passkey",
      status_id: StaffPasskeyStatus::ACTIVE,
    )

    get sign_org_configuration_passkey_url(other_passkey, ri: "jp"), headers: @headers
    assert_response :not_found
  end
end
