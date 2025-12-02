# frozen_string_literal: true

require "test_helper"

module Top::Com
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get top_com_root_url

      assert_response :success
    end

    # rubocop:disable Minitest/MultipleAssertions
    test "should display navigation links" do
      get top_com_root_url

      assert_response :success
      assert_select "h1", text: I18n.t("top.com.preferences.footer.home")
      assert_select "a[href^=?]", top_com_preference_path, text: I18n.t("top.com.preferences.footer.preference")
      assert_select "a[href^=?]", top_com_privacy_path, text: I18n.t("top.com.preferences.footer.privacy")
    end
    # rubocop:enable Minitest/MultipleAssertions
  end
end
