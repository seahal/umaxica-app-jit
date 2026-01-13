# frozen_string_literal: true

require "test_helper"

class Help::App::PreferenceControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get apex_app_preference_url(lx: "ja", ri: "jp")
    assert_response :success
  end

  test "preference page links to apex preference" do
    get apex_app_preference_url(lx: "ja", ri: "jp")
    assert_response :success
    assert_select "a[href*=?]", apex_app_preference_url,
                  text: "プリファレンス"
  end
end
