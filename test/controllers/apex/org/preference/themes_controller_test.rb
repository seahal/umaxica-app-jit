# frozen_string_literal: true

require "test_helper"

require_relative "../../../../support/cookie_helper"

module Apex
  module Org
    module Preference
      class ThemesControllerTest < ActionDispatch::IntegrationTest
        # rubocop:disable Minitest/MultipleAssertions
        test "renders theme edit page with system selected by default" do
          get edit_apex_org_preference_theme_url

          assert_response :success

          assert_select "h1", text: I18n.t("apex.org.preference.theme.edit.title")
          assert_select "p.theme-description", text: I18n.t("apex.org.preference.theme.edit.description")

          assert_select "form" do
            assert_select "legend", text: I18n.t("apex.org.preference.theme.edit.legend")
            assert_select "input[type='hidden'][name='_method'][value='patch']", count: 1
            assert_select "input[type='radio'][name='theme'][value='li'][checked]", count: 0
            assert_select "input[type='radio'][name='theme'][value='dr'][checked]", count: 0
            assert_select "input[type='radio'][name='theme'][value='sy'][checked]", count: 1
            assert_select "label[for='theme_light_org']", text: I18n.t("apex.org.preference.theme.edit.options.light")
            assert_select "label[for='theme_dark_org']", text: I18n.t("apex.org.preference.theme.edit.options.dark")
            assert_select "label[for='theme_system_org']", text: I18n.t("apex.org.preference.theme.edit.options.system")
            assert_select ".hint", text: I18n.t("apex.org.preference.theme.edit.hints.light")
            assert_select ".hint", text: I18n.t("apex.org.preference.theme.edit.hints.dark")
            assert_select ".hint", text: I18n.t("apex.org.preference.theme.edit.hints.system")
            assert_select "input[type='submit'][value=?]", I18n.t("apex.org.preference.theme.edit.submit")
          end

          assert_select "a.btn.btn-secondary[href^='#{apex_org_preference_path}']", text: I18n.t("apex.org.preferences.back_to_settings")
        end
        # rubocop:enable Minitest/MultipleAssertions

        # rubocop:disable Minitest/MultipleAssertions
        test "updates admin theme preference" do
          patch apex_org_preference_theme_url, params: { theme: "li", lx: "ja", ri: "jp", tz: "jst" }

          assert_redirected_to edit_apex_org_preference_theme_url(lx: "ja", ri: "jp", tz: "jst")
          assert_equal I18n.t("apex.org.preferences.themes.updated", theme: I18n.t("themes.light")), flash[:notice]
          assert_equal "light", session[:theme]
          assert_equal "light", signed_cookie(:apex_org_theme)

          follow_redirect!

          assert_response :success
          assert_select "input[type='radio'][name='theme'][value='li'][checked]", count: 1
          assert_select "a.btn.btn-secondary[href^='#{apex_org_preference_path}']", text: I18n.t("apex.org.preferences.back_to_settings")
        end
        # rubocop:enable Minitest/MultipleAssertions

        # rubocop:disable Minitest/MultipleAssertions
        test "handles invalid admin theme selection" do
          patch apex_org_preference_theme_url, params: { theme: "dr", lx: "ja", ri: "jp", tz: "jst" }

          assert_redirected_to edit_apex_org_preference_theme_url(lx: "ja", ri: "jp", tz: "jst")
          follow_redirect!

          assert_equal "dark", session[:theme]
          assert_equal "dark", signed_cookie(:apex_org_theme)
          assert_select "a.btn.btn-secondary[href^='#{apex_org_preference_path}']", text: I18n.t("apex.org.preferences.back_to_settings")

          patch apex_org_preference_theme_url, params: { theme: "business", lx: "ja", ri: "jp", tz: "jst" }

          assert_response :unprocessable_content
          assert_equal I18n.t("apex.org.preferences.themes.invalid"), flash[:alert]
          assert_equal "dark", session[:theme]
          assert_equal "dark", signed_cookie(:apex_org_theme)
          assert_select "input[type='radio'][name='theme'][value='dr'][checked]", count: 1
          assert_select "a.btn.btn-secondary[href^='#{apex_org_preference_path}']", text: I18n.t("apex.org.preferences.back_to_settings")
        end
        # rubocop:enable Minitest/MultipleAssertions
      end
    end
  end
end

