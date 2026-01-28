# frozen_string_literal: true

require "test_helper"

class Sign::App::PreferenceControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get apex_app_preference_url(ri: "jp", lx: "ja")
    assert_response :success
  end

  test "footer should contain preference link" do
    get sign_app_root_url(ri: "jp", lx: "ja")
    assert_response :success
    assert_match "footer", response.body
    assert_select "a[href*=?]", apex_app_preference_url
  end

  test "preference page links to apex preference" do
    get apex_app_preference_url(ri: "jp", lx: "ja")
    assert_response :success
    assert_select "a[href*=?]",
                  apex_app_preference_url,
                  text: "プリファレンス"
  end
end
