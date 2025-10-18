# frozen_string_literal: true

require "test_helper"

class Apex::Com::Preference::ThemesControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("APEX_CORPORATE_URL", "com.localhost:3333")
  end

  test "renders the theme edit page with theme form" do
    get edit_apex_com_preference_theme_url
    assert_response :success

    assert_select "h1", text: I18n.t("apex.app.preference.cookie.edit.h1")
    assert_select "form"
    assert_select "input[name=?]", "accept_necessary_cookies"
  end
end
