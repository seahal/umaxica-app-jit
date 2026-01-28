# frozen_string_literal: true

require "test_helper"

class Sign::Org::Configuration::PasskeysControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
    @host_headers = { "Host" => ENV["SIGN_STAFF_URL"] || "sign.org.localhost" }.freeze
    @headers = @host_headers.merge("X-TEST-CURRENT-STAFF" => @staff.id)
  end

  test "should get index" do
    get sign_org_configuration_passkeys_url(ri: "jp"), headers: @headers

    assert_response :success
    assert_select "h1", I18n.t("sign.org.configuration.passkeys.index.title")
  end

  # test "should get show" do
  #   # TODO: Implement show action test with actual passkey
  #   # skip "Implementation pending"
  # end

  test "should get new" do
    get new_sign_org_configuration_passkey_url(ri: "jp"), headers: @headers

    assert_response :success
    assert_select "h1", I18n.t("sign.org.configuration.passkeys.new.page_title")
  end

  test "redirects unauthenticated staff to login" do
    get sign_org_configuration_passkeys_url(ri: "jp"), headers: @host_headers

    assert_response :redirect
    assert_match new_sign_org_in_path, response.headers["Location"]
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
