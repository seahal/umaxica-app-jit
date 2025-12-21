# frozen_string_literal: true

require "test_helper"

require "json"
require_relative "../../../../support/cookie_helper"

module Peak
  module Org
    module Preference
      class ThemesControllerTest < ActionDispatch::IntegrationTest
        # rubocop:disable Minitest/MultipleAssertions
        test "renders theme edit page with system selected by default" do
          get edit_peak_org_preference_theme_url

          assert_response :success

          assert_select "h1", text: I18n.t("peak.org.preference.theme.edit.title")
          assert_select "p.theme-description", text: I18n.t("peak.org.preference.theme.edit.description")

          assert_select "form" do
            assert_select "legend", text: I18n.t("peak.org.preference.theme.edit.legend")
            assert_select "input[type='hidden'][name='_method'][value='patch']", count: 1
            assert_select "input[type='radio'][name='theme'][value='li'][checked]", count: 0
            assert_select "input[type='radio'][name='theme'][value='dr'][checked]", count: 0
            assert_select "input[type='radio'][name='theme'][value='sy'][checked]", count: 1
            assert_select "label[for='theme_light_org']", text: I18n.t("peak.org.preference.theme.edit.options.light")
            assert_select "label[for='theme_dark_org']", text: I18n.t("peak.org.preference.theme.edit.options.dark")
            assert_select "label[for='theme_system_org']", text: I18n.t("peak.org.preference.theme.edit.options.system")
            assert_select ".hint", text: I18n.t("peak.org.preference.theme.edit.hints.light")
            assert_select ".hint", text: I18n.t("peak.org.preference.theme.edit.hints.dark")
            assert_select ".hint", text: I18n.t("peak.org.preference.theme.edit.hints.system")
            assert_select "input[type='submit'][value=?]", I18n.t("peak.org.preference.theme.edit.submit")
          end

          # Verify back link exists (may not have specific CSS classes)
          assert_select "a[href^='#{peak_org_preference_path}']", minimum: 1
        end
        # rubocop:enable Minitest/MultipleAssertions

        # rubocop:disable Minitest/MultipleAssertions
        test "updates theme preference and persists to cookies" do
          patch peak_org_preference_theme_url, params: { theme: "dr", lx: "ja", ri: "jp", tz: "jst" }

          assert_response :redirect
          assert_equal "管理テーマをダークテーマに更新しました", flash[:notice]
          assert_equal "dark", session[:theme]
          assert_equal "dark", signed_cookie(:root_org_theme)

          # org doesn't use root_app_preferences cookie
          # persisted_preferences = JSON.parse(signed_cookie(:root_app_preferences))
          # assert_equal "dr", persisted_preferences["ct"]

          follow_redirect!

          # QueryCanonicalizer may cause another redirect to normalize query params
          follow_redirect! if response.redirect?

          assert_response :success
          assert_select "input[type='radio'][name='theme'][value='dr'][checked]", count: 1
          assert_select "a[href^='#{peak_org_preference_path}']", minimum: 1
        end
        # rubocop:enable Minitest/MultipleAssertions

        # rubocop:disable Minitest/MultipleAssertions
        test "re-renders edit on invalid theme selection" do
          patch peak_org_preference_theme_url, params: { theme: "li", lx: "ja", ri: "jp", tz: "jst" }

          assert_response :redirect
          follow_redirect!

          # QueryCanonicalizer may cause another redirect to normalize query params
          follow_redirect! if response.redirect?

          assert_equal "light", session[:theme]
          assert_equal "light", signed_cookie(:root_org_theme)
          assert_select "a[href^='#{peak_org_preference_path}']", minimum: 1

          patch peak_org_preference_theme_url, params: { theme: "neon", lx: "ja", ri: "jp", tz: "jst" }

          assert_response :unprocessable_content
          assert_equal "無効な管理テーマが選択されました", flash[:alert]
          assert_equal "light", session[:theme]
          assert_equal "light", signed_cookie(:root_org_theme)
          assert_select "input[type='radio'][name='theme'][value='li'][checked]", count: 1
          assert_select "a[href^='#{peak_org_preference_path}']", minimum: 1
        end
        # rubocop:enable Minitest/MultipleAssertions
      end
    end
  end
end
