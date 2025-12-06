# frozen_string_literal: true

require "test_helper"

module Apex::Com
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get apex_com_root_url

      assert_response :success
    end

    # rubocop:disable Minitest/MultipleAssertions
    test "should display navigation links" do
      get apex_com_root_url

      assert_select "footer" do
        assert_select "a", text: I18n.t("apex.com.preferences.footer.home")
        assert_select "a[href^=?]", apex_com_preference_path, text: I18n.t("apex.com.preferences.footer.preference")
        assert_select "a[href^=?]", apex_com_privacy_path, text: I18n.t("apex.com.preferences.footer.privacy")
      end
    end
    # rubocop:enable Minitest/MultipleAssertions
  end
end
