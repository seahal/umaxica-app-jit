# frozen_string_literal: true

require "test_helper"

class Sign::Org::PreferenceControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("APEX_STAFF_URL", "org.localhost")
  end

  test "should get show" do
    get apex_org_preference_url(ri: "jp", lx: "ja")
    assert_response :success
  end

  test "footer should contain preference link" do
    get sign_org_root_url(ri: "jp", lx: "ja")
    assert_response :success
    # follow_redirect!
    assert_response :success
    assert_match "footer", response.body
    assert_match apex_org_preference_url, response.body
  end

  test "preference page links to apex preference" do
    get apex_org_preference_url(ri: "jp", lx: "ja")
    assert_response :success
    assert_select "a[href*=?]",
                  apex_org_preference_url,
                  text: "プリファレンス"
  end
end
