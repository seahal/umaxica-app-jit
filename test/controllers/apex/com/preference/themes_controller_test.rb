# frozen_string_literal: true

require "test_helper"

module Apex
  module Com
    module Preference
      class ThemesControllerTest < ActionDispatch::IntegrationTest
        test "renders theme edit page with system selected by default" do
          get edit_apex_com_preference_theme_url
          assert_response :success

          assert_select "h1", text: I18n.t("apex.com.preference.theme.edit.title")
          assert_select "p.theme-description", text: I18n.t("apex.com.preference.theme.edit.description")

          assert_select "form" do
            assert_select "legend", text: I18n.t("apex.com.preference.theme.edit.legend")
            assert_select "input[type='hidden'][name='_method'][value='patch']", count: 1
            assert_select "input[type='radio'][name='theme'][value='light'][checked]", count: 0
            assert_select "input[type='radio'][name='theme'][value='dark'][checked]", count: 0
            assert_select "input[type='radio'][name='theme'][value='system'][checked]", count: 1
            assert_select "label[for='theme_light_com']", text: I18n.t("apex.com.preference.theme.edit.options.light")
            assert_select "label[for='theme_dark_com']", text: I18n.t("apex.com.preference.theme.edit.options.dark")
            assert_select "label[for='theme_system_com']", text: I18n.t("apex.com.preference.theme.edit.options.system")
            assert_select ".hint", text: I18n.t("apex.com.preference.theme.edit.hints.light")
            assert_select ".hint", text: I18n.t("apex.com.preference.theme.edit.hints.dark")
            assert_select ".hint", text: I18n.t("apex.com.preference.theme.edit.hints.system")
            assert_select "input[type='submit'][value=?]", I18n.t("apex.com.preference.theme.edit.submit")
          end
        end

        # test "updates corporate theme preference" do
        #   patch apex_com_preference_theme_url, params: { theme: "dark" }
        #
        #   assert_redirected_to edit_apex_com_preference_theme_url(lx: "ja", ri: "jp", tz: "jst")
        #   assert_equal I18n.t("apex.com.preferences.themes.updated", theme: I18n.t("themes.dark")), flash[:notice]
        #   assert_equal "dark", session[:theme]
        #   assert_equal "dark", signed_cookie(:apex_com_theme)
        #
        #   follow_redirect!
        #   assert_response :success
        #   assert_select "input[type='radio'][name='theme'][value='dark'][checked]", count: 1
        # end
        #
        # test "rejects invalid corporate theme selection" do
        #   patch apex_com_preference_theme_url, params: { theme: "system" }
        #   assert_redirected_to edit_apex_com_preference_theme_url(lx: "ja", ri: "jp", tz: "jst")
        #   follow_redirect!
        #   assert_equal "system", session[:theme]
        #
        #   patch apex_com_preference_theme_url, params: { theme: "sepia" }
        #
        #   assert_response :unprocessable_content
        #   assert_equal I18n.t("apex.com.preferences.themes.invalid"), flash[:alert]
        #   assert_equal "system", session[:theme]
        #   assert_select "input[type='radio'][name='theme'][value='system'][checked]", count: 1
        # end
      end
    end
  end
end
