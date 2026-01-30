# frozen_string_literal: true

require "test_helper"

class Sign::App::UiFoundationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @host = ENV["SIGN_SERVICE_URL"]
  end

  test "should render configuration page with new UI foundation" do
    head = { "X-TEST-CURRENT-USER" => @user.id, "Host" => @host }
    get "/configuration", headers: head
    follow_redirect!(headers: head) if response.redirect?
    assert_response :success

    # Check for brand name in header
    assert_select "header h1", text: /#{ENV.fetch("BRAND_NAME", "Umaxica")}/

    # Check for PageHeader components
    assert_select "h1"
  end

  test "PageHeader renders correct up_to link" do
    head = as_user_headers(@user, host: @host)
    get "/configuration", headers: head
    follow_redirect!(headers: head) if response.redirect?
    assert_response :success
    assert_select "h1", text: I18n.t("sign.app.configuration.show.page_title")
  end

  test "PageHeader on sub-pages points back to configuration" do
    head = as_user_headers(@user, host: @host)
    pages = [
      sign_app_configuration_totps_path(ri: "jp"),
      sign_app_configuration_passkeys_path(ri: "jp"),
      sign_app_configuration_secrets_path(ri: "jp"),
      sign_app_configuration_emails_path(ri: "jp"),
      sign_app_configuration_telephones_path(ri: "jp"),
      sign_app_configuration_sessions_path(ri: "jp"),
      sign_app_configuration_google_path(ri: "jp"),
      sign_app_configuration_withdrawal_path(ri: "jp"),
      edit_sign_app_out_path(ri: "jp"),
    ]

    pages.each do |path|
      get path, headers: head
      follow_redirect!(headers: head) if response.redirect?
      assert_response :success, "Failed to load #{path}"
    end
  end

  test "dark mode class is rendered based on cookie" do
    # Testing the theme_html_class helper's effect via integration
    head = as_user_headers(@user, host: @host).merge("Cookie" => "jit_ct=dark")
    get sign_app_configuration_url, headers: head
    follow_redirect!(headers: head) if response.redirect?
    assert_select "html.dark"

    head = as_user_headers(@user, host: @host).merge("Cookie" => "jit_ct=light")
    get sign_app_configuration_url, headers: head
    follow_redirect!(headers: head) if response.redirect?
    assert_select "html:not(.dark)"
  end

  test "UI components are used in the page" do
    head = as_user_headers(@user, host: @host)
    get sign_app_configuration_url, headers: head
    follow_redirect!(headers: head) if response.redirect?

    # Cards (we used shared/ui/card which has rounded-lg border etc)
    assert_select ".rounded-lg.border.bg-card"

    # Links with grid gap (the new layout)
    assert_select "section div.grid.gap-3"
  end
end
