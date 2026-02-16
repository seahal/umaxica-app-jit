# frozen_string_literal: true

require "test_helper"

class Core::Com::PreferenceControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("APEX_CORPORATE_URL", "com.localhost")
  end

  test "should get show" do
    get apex_com_preference_url(lx: "ja", ri: "jp")
    assert_response :success
  end

  test "footer should contain preference link" do
    get core_com_root_url
    assert_response :success
    assert_match "footer", response.body
    assert_match apex_com_preference_url, response.body
  end

  test "preference page links to apex preference" do
    get apex_com_preference_url(lx: "ja", ri: "jp")
    assert_response :success
    assert_select "a[href*=?]", apex_com_preference_url,
                  text: "プリファレンス"
  end
end
