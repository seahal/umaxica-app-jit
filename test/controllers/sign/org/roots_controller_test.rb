# frozen_string_literal: true

require "test_helper"

class Sign::Org::RootsControllerTest < ActionDispatch::IntegrationTest
  test "GET / renders root page" do
    get sign_org_root_url

    assert_response :success
    assert_select "a[href*=?]", new_sign_org_up_path
    assert_select "a[href*=?]", new_sign_org_in_path
  end

  test "renders layout contract" do
    get sign_org_root_url

    assert_response :success
    assert_layout_contract
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "footer contains navigation links" do
    get sign_org_root_url

    assert_response :success
    assert_select "footer" do
      assert_select "a"
      assert_select "a[href*=?]", sign_org_preference_path, text: I18n.t("sign.org.preferences.footer.preference")
      assert_select "a[href*=?]", sign_org_configuration_path, text: I18n.t("sign.org.preferences.footer.configuration")
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "generates sha3-384 token digest on root" do
    get sign_org_root_url
    assert_response :success
    assert_equal 48, OrgPreference.order(:created_at).last.token_digest.bytesize
  end
end
