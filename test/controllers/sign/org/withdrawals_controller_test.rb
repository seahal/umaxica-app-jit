require "test_helper"

class Sign::Org::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_sign_org_withdrawal_url, headers: { "Host" => ENV["SIGN_STAFF_URL"] }

    assert_response :success
  end

  test "sets lang attribute on html element" do
    get new_sign_org_withdrawal_url(format: :html)

    assert_response :success
    assert_not_select("html[lang=?]", "")
    assert_select("html[lang=?]", "ja")
  end

  test "should create withdrawal" do
    post sign_org_withdrawal_url, headers: { "Host" => ENV["SIGN_STAFF_URL"] }

    assert_redirected_to %r{\A#{sign_org_root_url}}
  end
end
