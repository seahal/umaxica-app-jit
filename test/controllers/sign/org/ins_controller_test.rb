# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Org::InsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
  end

  test "should get new" do
    get new_sign_org_in_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :success
  end

  test "renders authentication links" do
    get new_sign_org_in_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :success

    query = { ri: "jp" }
    assert_select "a[href=?]", new_sign_org_in_passkey_path(query)
    assert_select "a[href=?]", new_sign_org_in_secret_path(query)
  end

  test "renders back to root link" do
    get new_sign_org_in_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :success

    assert_select "a[href=?]", apex_org_root_path(ri: "jp"), text: "ホーム"
  end
end
