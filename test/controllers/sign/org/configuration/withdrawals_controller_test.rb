# frozen_string_literal: true

require "test_helper"

class Sign::Org::Configuration::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
  end

  test "should get show" do
    get sign_org_configuration_withdrawal_url(ri: "jp"),
        headers: { "Host" => @host, "X-TEST-CURRENT-STAFF" => @staff.id }
    assert_response :success
  end
end
