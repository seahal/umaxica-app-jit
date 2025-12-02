# frozen_string_literal: true

require "test_helper"

module Top::Org
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get top_org_root_url

      assert_response :success
    end

    # rubocop:disable Minitest/MultipleAssertions
    test "should display navigation links" do
      get top_org_root_url

      assert_response :success
      assert_select "h1", text: I18n.t("top.org.preferences.footer.home")
      assert_select "a[href^=?]", top_org_preference_path, text: I18n.t("top.org.preferences.footer.preference")
      assert_select "a[href^=?]", top_org_privacy_path, text: I18n.t("top.org.preferences.footer.privacy")
    end
    # rubocop:enable Minitest/MultipleAssertions
  end
end
