# frozen_string_literal: true

require "test_helper"

module Apex::App
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get apex_app_root_url

      assert_response :success
    end

    test "renders layout contract" do
      get apex_app_root_url

      assert_response :success
      assert_layout_contract
    end

    # rubocop:disable Minitest/MultipleAssertions
    test "should display navigation links" do
      get apex_app_root_url

      assert_select "a", text: "Umaxica(app)"

      assert_select "footer" do
        assert_select "a", text: I18n.t("apex.app.preferences.footer.home")
        assert_select "a[href^=?]", apex_app_preference_path, text: I18n.t("apex.app.preferences.footer.preference")
      end

      assert_select "a[href^=?]", apex_app_configuration_path
    end
    # rubocop:enable Minitest/MultipleAssertions
  end
end
