# frozen_string_literal: true

require "test_helper"

class Sign::App::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get sign_app_preference_url(ri: "jp")
    assert_response :success
  end

  test "footer should contain preference link" do
    get sign_app_root_url(ri: "jp")
    assert_response :success
    assert_match "footer", response.body
    assert_select "a[href*=?]", sign_app_preference_path(ri: "jp")
  end

  test "preference page links to apex preference" do
    get sign_app_preference_url(ri: "jp")
    assert_response :success
    assert_select "a[href*=?]",
                  apex_app_preference_url(ri: "jp"),
                  text: I18n.t("shared.links.apex_preference")
  end
end
