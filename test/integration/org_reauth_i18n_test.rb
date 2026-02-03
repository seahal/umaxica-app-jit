# frozen_string_literal: true

require "test_helper"

class OrgReauthI18nTest < ActionDispatch::IntegrationTest
  fixtures :staffs

  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    host! @host
    @staff = staffs(:one)
    @token = StaffToken.create!(
      staff: @staff,
      staff_token_status_id: StaffTokenStatus::NEYO,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      public_id: "org_i18n_#{SecureRandom.hex(5)}",
      refresh_expires_at: 1.day.from_now,
    )
    @headers = {
      "X-TEST-CURRENT-STAFF" => @staff.id.to_s,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }.freeze
  end

  test "index view displays translated strings in Japanese" do
    ReauthSession.delete_all

    get sign_org_reauth_index_url(ri: "jp"), headers: @headers
    assert_response :success
    assert_select "h1", text: I18n.t("sign.org.reauth.index.title", locale: :ja)
    assert_select "td", text: I18n.t("sign.org.reauth.index.empty", locale: :ja)
  end

  test "index view displays translated strings in English" do
    ReauthSession.delete_all

    get sign_org_reauth_index_url(ri: "us"), headers: @headers
    assert_response :success
    assert_select "h1", text: I18n.t("sign.org.reauth.index.title", locale: :en)
    assert_select "td", text: I18n.t("sign.org.reauth.index.empty", locale: :en)
  end
end
