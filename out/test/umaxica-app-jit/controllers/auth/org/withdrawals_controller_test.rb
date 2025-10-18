require "test_helper"

class Auth::Org::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_auth_org_withdrawal_url, headers: { "Host" => ENV["AUTH_STAFF_URL"] }
    assert_response :success
  end

  test "should get html which must have html which contains lang param." do
    get new_auth_org_withdrawal_url(format: :html)
    assert_response :success
    assert_not_select("html[lang=?]", "")
    assert_select("html[lang=?]", "ja")
  end

  # test "should get edit" do
  #   # TODO: Implement edit action test
  #   # skip "Implementation pending"
  # end

  # test "should post create" do
  #   # TODO: Implement create action test
  #   # skip "Implementation pending"
  # end

  # test "should patch update" do
  #   # TODO: Implement update action test
  #   # skip "Implementation pending"
  # end
end
