# frozen_string_literal: true

require "test_helper"

module Apex
  module Org
    module Preference
      class ThemesControllerTest < ActionDispatch::IntegrationTest
        test "renders theme edit page with light and dark options" do
          get edit_apex_org_preference_theme_url
          assert_response :success

          assert_select "h1", text: I18n.t("apex.org.preference.theme.edit.title")
          assert_select "p.theme-description", text: I18n.t("apex.org.preference.theme.edit.description")

          expected_action = apex_org_preference_theme_path
          assert_select "form[action=?]", expected_action do
            assert_select "legend", text: I18n.t("apex.org.preference.theme.edit.legend")
            assert_select "input[type='hidden'][name='_method'][value='patch']", count: 1
            assert_select "input[type='radio'][name='theme'][value='light'][checked]", count: 1
            assert_select "input[type='radio'][name='theme'][value='dark']", count: 1
            assert_select "label[for='theme_light_org']", text: I18n.t("apex.org.preference.theme.edit.options.light")
            assert_select "label[for='theme_dark_org']", text: I18n.t("apex.org.preference.theme.edit.options.dark")
            assert_select ".hint", text: I18n.t("apex.org.preference.theme.edit.hints.light")
            assert_select ".hint", text: I18n.t("apex.org.preference.theme.edit.hints.dark")
            assert_select "input[type='submit'][value=?]", I18n.t("apex.org.preference.theme.edit.submit")
          end
        end
      end
    end
  end
end
