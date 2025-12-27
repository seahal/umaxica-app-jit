# frozen_string_literal: true

require "test_helper"

require_relative "../../../../support/cookie_helper"

module Peak
  module App
    module Preference
      class ThemesControllerTest < ActionDispatch::IntegrationTest
        setup do
          https!
        end

        # rubocop:disable Minitest/MultipleAssertions
        test "renders theme edit page with system selected by default 2" do
          get edit_peak_app_preference_theme_url

          assert_response :success

          assert_select "h1", text: I18n.t("peak.app.preference.theme.edit.title")
          assert_select "p.theme-description", text: I18n.t("peak.app.preference.theme.edit.description"), count: 1

          assert_select "form" do
            assert_select "legend", text: I18n.t("peak.app.preference.theme.edit.legend")
            assert_select "input[type='hidden'][name='_method'][value='patch']", count: 1
            assert_select "input[type='radio'][name='theme'][value='li'][checked]", count: 0
            assert_select "input[type='radio'][name='theme'][value='dr'][checked]", count: 0
            assert_select "input[type='radio'][name='theme'][value='sy'][checked]", count: 1
            # New layout uses span for label text inside label tag
            assert_select "label[for='theme_light_app']"
            assert_select "label[for='theme_dark_app']"
            assert_select "label[for='theme_system_app']"
            # New layout uses p tags for hints
            assert_select "p", text: I18n.t("peak.app.preference.theme.edit.hints.light")
            assert_select "p", text: I18n.t("peak.app.preference.theme.edit.hints.dark")
            assert_select "p", text: I18n.t("peak.app.preference.theme.edit.hints.system")
            assert_select "input[type='submit'][value=?]", I18n.t("peak.app.preference.theme.edit.submit")
          end

          assert_select "a", text: I18n.t("peak.app.preferences.back_to_settings")
        end
        # rubocop:enable Minitest/MultipleAssertions

        # rubocop:disable Minitest/MultipleAssertions
        test "updates theme preference and persists to cookies" do
          patch peak_app_preference_theme_url, params: { theme: "dr", lx: "ja", ri: "jp", tz: "jst" }

          assert_response :redirect
          assert_equal "テーマをダークテーマに更新しました", flash[:notice]
          assert_equal "dark", session[:theme]
          assert_equal "dark", signed_cookie(:root_app_theme)

          persisted_preferences = preference_cookie_payload(:"__Secure-root_app_preferences")

          assert_equal "dr", persisted_preferences["ct"]

          follow_redirect!

          # QueryCanonicalizer may cause another redirect to normalize query params
          follow_redirect! if response.redirect?

          assert_response :success
          assert_select "input[type='radio'][name='theme'][value='dr'][checked]", count: 1
          assert_select "a[href^='#{peak_app_preference_path}']", minimum: 1
        end
        # rubocop:enable Minitest/MultipleAssertions

        # rubocop:disable Minitest/MultipleAssertions
        test "re-renders edit on invalid theme selection" do
          patch peak_app_preference_theme_url, params: { theme: "li", lx: "ja", ri: "jp", tz: "jst" }

          assert_response :redirect
          follow_redirect!

          # QueryCanonicalizer may cause another redirect to normalize query params
          follow_redirect! if response.redirect?

          assert_equal "light", session[:theme]
          assert_equal "light", signed_cookie(:root_app_theme)
          assert_select "a[href^='#{peak_app_preference_path}']", minimum: 1

          patch peak_app_preference_theme_url, params: { theme: "neon", lx: "ja", ri: "jp", tz: "jst" }

          assert_response :unprocessable_content
          assert_equal "無効なテーマが選択されました", flash[:alert]
          assert_equal "light", session[:theme]
          assert_equal "light", signed_cookie(:root_app_theme)
          assert_select "input[type='radio'][name='theme'][value='li'][checked]", count: 1
          assert_select "a[href^='#{peak_app_preference_path}']", minimum: 1
        end
        # rubocop:enable Minitest/MultipleAssertions
      end
    end
  end
end
