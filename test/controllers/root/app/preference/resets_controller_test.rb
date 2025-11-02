# frozen_string_literal: true

require "test_helper"

require_relative "../../../../support/cookie_helper"

module Root
  module App
    module Preference
      class ResetsControllerTest < ActionDispatch::IntegrationTest
        test "renders reset confirmation form" do
          get edit_root_app_preference_reset_url

          assert_response :success
          assert_select "h1", text: I18n.t("root.app.preference.reset.edit.title")
          assert_select "form" do
            assert_select "input[type='hidden'][name='_method'][value='delete']", count: 1
            assert_select "input[type='checkbox'][name='confirm_reset']", count: 1
            assert_select "label[for='confirm_reset']", text: I18n.t("root.app.preference.reset.edit.confirmation_label")
            assert_select "input[type='submit'][value='#{I18n.t("root.app.preference.reset.edit.submit")}']", count: 1
          end
          assert_select "a.btn.btn-secondary",
                        text: I18n.t("root.app.preferences.back_to_settings"),
                        count: 1
        end

        test "clears preference cookies when confirmation checkbox is selected" do
          patch root_app_preference_region_url, params: { region: "JP", language: "JA", timezone: "Asia/Tokyo" }
          assert_predicate signed_cookie(:root_app_preferences), :present?

          delete root_app_preference_reset_url, params: { confirm_reset: "1" }

          assert_response :redirect
          assert_match %r{^#{Regexp.escape(root_app_preference_url)}}, response.location
          assert_equal I18n.t("root.app.preference.reset.destroy.success"), flash[:notice]
          assert_nil signed_cookie(:root_app_preferences)

          follow_redirect!

          assert_response :success
        end

        test "re-renders edit when confirmation checkbox is not selected" do
          patch root_app_preference_region_url, params: { region: "JP", language: "JA" }
          original_cookie = signed_cookie(:root_app_preferences)
          assert_predicate original_cookie, :present?

          delete root_app_preference_reset_url

          assert_response :unprocessable_content
          assert_equal I18n.t("root.app.preference.reset.destroy.confirmation_required"), flash[:alert]
          assert_equal original_cookie, signed_cookie(:root_app_preferences)
          assert_select "form", count: 1
        end
      end
    end
  end
end
