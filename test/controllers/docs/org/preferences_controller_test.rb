# frozen_string_literal: true

require "test_helper"

class Docs::Org::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get docs_org_preference_url
    assert_response :success
  end

  test "footer should contain preference link" do
    get docs_org_root_url
    assert_response :success
    assert_match "footer", response.body
    assert_match docs_org_preference_path, response.body
  end

  test "preference page includes link to apex preference" do
    get docs_org_preference_url
    assert_response :success
    assert_select "a[href*=?]",
                  apex_org_preference_url,
                  text: I18n.t("shared.links.apex_preference")
  end
end
