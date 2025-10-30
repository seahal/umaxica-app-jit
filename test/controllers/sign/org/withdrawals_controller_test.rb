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

  test "should get edit" do
    get edit_sign_org_withdrawal_url, headers: { "Host" => ENV["SIGN_STAFF_URL"] }

    assert_response :success
  end

  test "should respond to create action" do
    # Test that the controller has a create action
    assert_includes Sign::Org::WithdrawalsController.instance_methods, :create
  end

  test "should patch update" do
    patch sign_org_withdrawal_url, headers: { "Host" => ENV["SIGN_STAFF_URL"] }

    assert_response :success
  end
end
