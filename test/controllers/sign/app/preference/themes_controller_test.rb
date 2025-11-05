# frozen_string_literal: true

require "test_helper"

require "json"
require_relative "../../../../support/cookie_helper"

module Sign
  module App
    module Preference
      class ThemesControllerTest < ActionDispatch::IntegrationTest
        # rubocop:disable Minitest/MultipleAssertions
        test "renders theme edit page with system selected by default" do
          get edit_sign_app_preference_theme_url

          assert_response :success

          assert_select "h1", text: I18n.t("sign.app.preference.theme.edit.title")
          assert_select "p.theme-description", text: I18n.t("sign.app.preference.theme.edit.description")

          assert_select "form" do
            assert_select "legend", text: I18n.t("sign.app.preference.theme.edit.legend")
            assert_select "input[type='hidden'][name='_method'][value='patch']", count: 1
            assert_select "input[type='radio'][name='theme'][value='li'][checked]", count: 0
            assert_select "input[type='radio'][name='theme'][value='dr'][checked]", count: 0
            assert_select "input[type='radio'][name='theme'][value='sy'][checked]", count: 1
            assert_select "label[for='theme_light_app']", text: I18n.t("sign.app.preference.theme.edit.options.light")
            assert_select "label[for='theme_dark_app']", text: I18n.t("sign.app.preference.theme.edit.options.dark")
            assert_select "label[for='theme_system_app']", text: I18n.t("sign.app.preference.theme.edit.options.system")
            assert_select ".hint", text: I18n.t("sign.app.preference.theme.edit.hints.light")
            assert_select ".hint", text: I18n.t("sign.app.preference.theme.edit.hints.dark")
            assert_select ".hint", text: I18n.t("sign.app.preference.theme.edit.hints.system")
            assert_select "input[type='submit'][value=?]", I18n.t("sign.app.preference.theme.edit.submit")
          end

          assert_select "a[href^='#{sign_app_preference_path}']", text: I18n.t("sign.app.preferences.back_to_settings"), count: 1
        end
        # rubocop:enable Minitest/MultipleAssertions

        # rubocop:disable Minitest/MultipleAssertions
        test "updates theme preference and persists to cookies" do
          patch sign_app_preference_theme_url, params: { theme: "dr", lx: "ja", ri: "jp", tz: "jst" }

          assert_redirected_to edit_sign_app_preference_theme_url(lx: "ja", ri: "jp", tz: "jst")
          assert_equal I18n.t("sign.app.preferences.themes.updated", theme: I18n.t("themes.dark")), flash[:notice]
          assert_equal "dark", session[:theme]
          assert_equal "dark", signed_cookie(:root_app_theme)

          persisted_preferences = JSON.parse(signed_cookie(:root_app_preferences))

          assert_equal "dr", persisted_preferences["ct"]

          follow_redirect!

          assert_response :success
          assert_select "input[type='radio'][name='theme'][value='dr'][checked]", count: 1
          assert_select "a.btn.btn-secondary[href^='#{sign_app_preference_path}']", text: I18n.t("sign.app.preferences.back_to_settings")
        end
        # rubocop:enable Minitest/MultipleAssertions

        # rubocop:disable Minitest/MultipleAssertions
        test "re-renders edit on invalid theme selection" do
          patch sign_app_preference_theme_url, params: { theme: "li", lx: "ja", ri: "jp", tz: "jst" }

          assert_redirected_to edit_sign_app_preference_theme_url(lx: "ja", ri: "jp", tz: "jst")
          follow_redirect!

          assert_equal "light", session[:theme]
          assert_equal "light", signed_cookie(:root_app_theme)
          assert_select "a.btn.btn-secondary[href^='#{sign_app_preference_path}']", text: I18n.t("sign.app.preferences.back_to_settings")

          patch sign_app_preference_theme_url, params: { theme: "neon", lx: "ja", ri: "jp", tz: "jst" }

          assert_response :unprocessable_content
          assert_equal I18n.t("sign.app.preferences.themes.invalid"), flash[:alert]
          assert_equal "light", session[:theme]
          assert_equal "light", signed_cookie(:root_app_theme)
          assert_select "input[type='radio'][name='theme'][value='li'][checked]", count: 1
          assert_select "a.btn.btn-secondary[href^='#{sign_app_preference_path}']", text: I18n.t("sign.app.preferences.back_to_settings")
        end
        # rubocop:enable Minitest/MultipleAssertions
      end
    end
  end
end
