# frozen_string_literal: true

require "test_helper"

class Docs::App::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get docs_app_preference_url
    assert_response :success
  end

  test "footer should contain preference link" do
    get docs_app_root_url
    assert_response :success
    assert_match "footer", response.body
    assert_match docs_app_preference_path, response.body
  end

  test "preference page links to apex preference" do
    get docs_app_preference_url
    assert_response :success
    assert_select "a[href=?]",
                  apex_app_preference_url(ri: "jp"),
                  text: I18n.t("shared.links.apex_preference")
  end
end
