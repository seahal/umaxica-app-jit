# frozen_string_literal: true

require "test_helper"
require "json"

module Apex
  module App
    module Preference
      class ThemesControllerTest < ActionDispatch::IntegrationTest
        test "renders theme edit page with system selected by default" do
          get edit_apex_app_preference_theme_url
          assert_response :success

          assert_select "h1", text: I18n.t("apex.app.preference.theme.edit.title")
          assert_select "p.theme-description", text: I18n.t("apex.app.preference.theme.edit.description")

          assert_select "form" do
            assert_select "legend", text: I18n.t("apex.app.preference.theme.edit.legend")
            assert_select "input[type='hidden'][name='_method'][value='patch']", count: 1
            assert_select "input[type='radio'][name='theme'][value='light'][checked]", count: 0
            assert_select "input[type='radio'][name='theme'][value='dark'][checked]", count: 0
            assert_select "input[type='radio'][name='theme'][value='system'][checked]", count: 1
            assert_select "label[for='theme_light_app']", text: I18n.t("apex.app.preference.theme.edit.options.light")
            assert_select "label[for='theme_dark_app']", text: I18n.t("apex.app.preference.theme.edit.options.dark")
            assert_select "label[for='theme_system_app']", text: I18n.t("apex.app.preference.theme.edit.options.system")
            assert_select ".hint", text: I18n.t("apex.app.preference.theme.edit.hints.light")
            assert_select ".hint", text: I18n.t("apex.app.preference.theme.edit.hints.dark")
            assert_select ".hint", text: I18n.t("apex.app.preference.theme.edit.hints.system")
            assert_select "input[type='submit'][value=?]", I18n.t("apex.app.preference.theme.edit.submit")
          end
        end

        # test "updates theme preference and persists to cookies" do
        #   patch apex_app_preference_theme_url, params: { theme: "dark" }
        #
        #   assert_redirected_to edit_apex_app_preference_theme_url(lx: "ja", ri: "jp", tz: "jst")
        #   assert_equal I18n.t("apex.app.preferences.themes.updated", theme: I18n.t("themes.dark")), flash[:notice]
        #   assert_equal "dark", session[:theme]
        #   assert_equal "dark", signed_cookie(:apex_app_theme)
        #
        #   persisted_preferences = JSON.parse(signed_cookie(:apex_app_preferences))
        #   assert_equal "dark", persisted_preferences["ct"]
        #
        #   follow_redirect!
        #   assert_response :success
        #   assert_select "input[type='radio'][name='theme'][value='dark'][checked]", count: 1
        # end
        #
        # test "re-renders edit on invalid theme selection" do
        #   patch apex_app_preference_theme_url, params: { theme: "light" }
        #   assert_redirected_to edit_apex_app_preference_theme_url(lx: "ja", ri: "jp", tz: "jst")
        #   follow_redirect!
        #   assert_equal "light", session[:theme]
        #
        #   patch apex_app_preference_theme_url, params: { theme: "neon" }
        #
        #   assert_response :unprocessable_content
        #   assert_equal I18n.t("apex.app.preferences.themes.invalid"), flash[:alert]
        #   assert_equal "light", session[:theme]
        #   assert_select "input[type='radio'][name='theme'][value='light'][checked]", count: 1
        # end
      end
    end
  end
end
