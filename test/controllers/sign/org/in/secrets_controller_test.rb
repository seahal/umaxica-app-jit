# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Org::In::SecretsControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_secrets, :staff_statuses, :staff_secret_statuses, :staff_secret_kinds

  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    host! @host
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }
    @staff = staffs(:sample_staff)
    @staff.update!(status_id: StaffStatus::ACTIVE)
    @raw_secret = "11111111111111111111111111111111"
  end

  teardown do
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

  test "should get new" do
    get new_sign_org_in_secret_url(ri: "jp")

    assert_response :success
    assert_select "label", text: "ID"
    assert_select "input[name='secret_login_form[identifier]'][required]"
    assert_select "input[name='secret_login_form[identifier]'][minlength='16']"
    assert_select "input[name='secret_login_form[identifier]'][maxlength='16']"
    assert_select "input[name='secret_login_form[identifier]'][pattern='[0-9A-FGHJKMNPQRSTVWXYZ]{16}']"
    assert_select "input[name='secret_login_form[identifier]'][autocapitalize='characters']"
    assert_select "input[name='secret_login_form[identifier]'][spellcheck='false']"
    assert_select "input[name='secret_login_form[totp_code]']", count: 0
  end

  test "create signs in with staff public_id and secret" do
    post sign_org_in_secret_url(ri: "jp"),
         params: {
           secret_login_form: {
             identifier: @staff.public_id.downcase,
             secret_value: @raw_secret,
           },
         }

    assert_response :redirect
    assert_includes response.headers["Location"], "/in/checkpoint"
    assert_equal StaffSecretStatus::USED, staff_secrets(:sample_login).reload.staff_secret_status_id
  end

  test "create rejects blank form" do
    post sign_org_in_secret_url(ri: "jp"),
         params: { secret_login_form: { identifier: "", secret_value: "" } }

    assert_response :unprocessable_content
    assert_equal StaffSecretStatus::ACTIVE, staff_secrets(:sample_login).reload.staff_secret_status_id
  end

  test "create rejects email identifier" do
    post sign_org_in_secret_url(ri: "jp"),
         params: {
           secret_login_form: {
             identifier: "staff_test@example.com",
             secret_value: @raw_secret,
           },
         }

    assert_response :unprocessable_content
    assert_equal StaffSecretStatus::ACTIVE, staff_secrets(:sample_login).reload.staff_secret_status_id
  end

  test "create rejects invalid secret" do
    post sign_org_in_secret_url(ri: "jp"),
         params: {
           secret_login_form: {
             identifier: @staff.public_id,
             secret_value: "wrong-secret-value-000000000000",
           },
         }

    assert_response :unprocessable_content
    assert_equal StaffSecretStatus::ACTIVE, staff_secrets(:sample_login).reload.staff_secret_status_id
  end
end
