# frozen_string_literal: true

require "test_helper"

class OrgVerificationI18nTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_statuses

  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    host! @host
    @staff = staffs(:one)
    @token = StaffToken.create!(
      staff: @staff,
      staff_token_status_id: StaffTokenStatus::NEYO,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      public_id: "ov_i18n_#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
    )
    @headers = browser_headers.merge(
      "X-TEST-CURRENT-STAFF" => @staff.id.to_s,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    ).freeze

    StaffPasskey.create!(
      staff: @staff,
      name: "verify i18n passkey",
      webauthn_id: "org-verify-i18n-#{SecureRandom.hex(4)}",
      external_id: SecureRandom.uuid,
      public_key: "public_key",
      sign_count: 0,
      status_id: StaffPasskeyStatus::ACTIVE,
    )
  end

  test "verification view displays translated strings in Japanese" do
    ReauthSession.delete_all

    get sign_org_verification_url(ri: "jp"), headers: @headers
    assert_response :success
    assert_select "h1", text: I18n.t("sign.org.verification.index.title", locale: :ja)
    assert_select "h2", text: I18n.t("sign.org.verification.new.title", locale: :ja)
  end

  test "verification view displays translated strings in English" do
    ReauthSession.delete_all

    get sign_org_verification_url(ri: "us"), headers: @headers
    assert_response :success
    assert_select "h1", text: I18n.t("sign.org.verification.index.title", locale: :en)
    assert_select "h2", text: I18n.t("sign.org.verification.new.title", locale: :en)
  end
end
