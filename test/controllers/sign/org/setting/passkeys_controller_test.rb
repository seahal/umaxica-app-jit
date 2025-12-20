require "test_helper"

class Sign::Org::Setting::PasskeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @staff = staffs(:one)
    @host_headers = { "Host" => ENV["SIGN_STAFF_URL"] || "sign.org.localhost" }.freeze
    @headers = @host_headers.merge("X-TEST-CURRENT-STAFF" => @staff.id)
  end

  test "should get index" do
    get sign_org_setting_passkeys_url, headers: @headers

    assert_response :success
    assert_equal I18n.t("errors.not_implemented"), response.body
  end

  # test "should get show" do
  #   # TODO: Implement show action test with actual passkey
  #   # skip "Implementation pending"
  # end

  test "should get new" do
    get new_sign_org_setting_passkey_url, headers: @headers

    assert_response :success
    assert_equal I18n.t("errors.not_implemented"), response.body
  end

  test "redirects unauthenticated staff to login" do
    get sign_org_setting_passkeys_url, headers: @host_headers

    assert_response :redirect
    assert_match new_sign_org_authentication_path, response.headers["Location"]
  end

  # test "should get edit" do
  #   # TODO: Implement edit action test with actual passkey
  #   # skip "Implementation pending"
  # end
  #
  # test "should post create" do
  #   # TODO: Implement create action test
  #   # skip "Implementation pending"
  # end
  #
  # test "should patch update" do
  #   # TODO: Implement update action test with actual passkey
  #   # skip "Implementation pending"
  # end
  #
  # test "should delete destroy" do
  #   # TODO: Implement destroy action test with actual passkey
  #   # skip "Implementation pending"
  # end
end
