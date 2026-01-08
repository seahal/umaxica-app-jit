# frozen_string_literal: true

require "test_helper"

module Apex::Org
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get apex_org_root_url

      assert_response :success
    end

    test "renders layout contract" do
      get apex_org_root_url

      assert_response :success
      assert_layout_contract
    end

    # rubocop:disable Minitest/MultipleAssertions
    test "should display navigation links" do
      get apex_org_root_url

      assert_select "a", text: "Umaxica(org)"

      assert_select "footer" do
        assert_select "a", text: I18n.t("apex.org.preferences.footer.home")
        assert_select "a[href^=?]", apex_org_preference_path, text: I18n.t("apex.org.preferences.footer.preference")
      end

      assert_select "a[href^=?]", apex_org_configuration_path
    end
    # rubocop:enable Minitest/MultipleAssertions

    test "generates sha3-384 token digest on root" do
      get apex_org_root_url
      assert_response :success
      assert_equal 48, OrgPreference.order(:created_at).last.token_digest.bytesize
    end
  end
end
