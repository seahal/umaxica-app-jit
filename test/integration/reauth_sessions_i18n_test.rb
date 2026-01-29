# frozen_string_literal: true

require "test_helper"

class ReauthSessionsI18nTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    host! @host
    @user = users(:one)
    @token = UserToken.create!(
      user: @user,
      user_token_status_id: "NEYO",
      user_token_kind_id: "BROWSER_WEB",
      public_id: "re_i18n_#{SecureRandom.hex(5)}",
      refresh_expires_at: 1.day.from_now,
    )
    @headers = {
      "X-TEST-CURRENT-USER" => @user.id.to_s,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }.freeze
  end

  test "index view displays translated strings in Japanese" do
    ReauthSession.delete_all

    get sign_app_reauth_index_url(ri: "jp"), headers: @headers
    assert_response :success
    puts "DEBUG: Locale=#{I18n.locale}"
    puts "DEBUG: Key check=#{I18n.t("sign.app.reauth.index.title", locale: :ja)}"
    assert_select "h1", text: I18n.t("sign.app.reauth.index.title", locale: :ja)
    assert_select "td", text: I18n.t("sign.app.reauth.index.empty", locale: :ja)
  end

  test "index view displays translated strings in English" do
    ReauthSession.delete_all

    get sign_app_reauth_index_url(ri: "us"), headers: @headers
    assert_response :success
    assert_select "h1", text: I18n.t("sign.app.reauth.index.title", locale: :en)
    assert_select "td", text: I18n.t("sign.app.reauth.index.empty", locale: :en)
  end
end
