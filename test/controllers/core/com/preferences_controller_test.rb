# frozen_string_literal: true

require "test_helper"

class Core::Com::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get core_com_preference_url
    assert_response :success
  end

  test "footer should contain preference link" do
    get core_com_root_url
    assert_response :success
    assert_match "footer", response.body
    assert_match core_com_preference_path, response.body
  end

  test "preference page links to apex preference" do
    get core_com_preference_url
    assert_response :success
    assert_select "a[href=?]", apex_com_preference_url, text: I18n.t("shared.links.apex_preference")
  end
end
