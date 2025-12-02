# frozen_string_literal: true

require "test_helper"

module Top::App
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get top_app_root_url

      assert_response :success
    end

    # rubocop:disable Minitest/MultipleAssertions
    test "should display navigation links" do
      get top_app_root_url

      assert_select "footer" do
      assert_select "a", text: I18n.t("top.app.preferences.footer.home")
      assert_select "a[href^=?]", top_app_preference_path, text: I18n.t("top.app.preferences.footer.preference")
      assert_select "a[href^=?]", top_app_privacy_path, text: I18n.t("top.app.preferences.footer.privacy")
      end
    end
    # rubocop:enable Minitest/MultipleAssertions
  end
end
