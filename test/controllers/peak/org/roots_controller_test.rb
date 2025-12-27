# frozen_string_literal: true

require "test_helper"

module Peak::Org
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get peak_org_root_url

      assert_response :success
    end

    test "renders layout contract" do
      get peak_org_root_url

      assert_response :success
      assert_layout_contract
    end

    # rubocop:disable Minitest/MultipleAssertions
    test "should display navigation links" do
      get peak_org_root_url

      assert_select "footer" do
        assert_select "a", text: I18n.t("peak.org.preferences.footer.home")
        assert_select "a[href^=?]", peak_org_preference_path, text: I18n.t("peak.org.preferences.footer.preference")
        assert_select "a[href^=?]", peak_org_privacy_path, text: I18n.t("peak.org.preferences.footer.privacy")
      end
    end
    # rubocop:enable Minitest/MultipleAssertions
  end
end
