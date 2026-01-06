# frozen_string_literal: true

require "test_helper"

class Core::App::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get core_app_preference_url
    assert_response :success
  end

  test "footer should contain preference link" do
    get core_app_root_url
    assert_response :success
    assert_match "footer", response.body
    assert_match core_app_preference_path, response.body
  end

  test "preference page includes app.localhost link" do
    get core_app_preference_url
    assert_response :success
    assert_select "a[href=?]", core_app_preference_url(host: "app.localhost")
  end

  test "preference page links to apex preference" do
    get core_app_preference_url
    assert_response :success
    assert_select "a[href=?]", apex_app_preference_url, text: I18n.t("shared.links.apex_preference")
  end
end
