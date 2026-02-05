# frozen_string_literal: true

require "test_helper"

class Sign::Org::Configuration::OutsControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_statuses

  setup do
    host! ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
    @host = ENV["SIGN_STAFF_URL"] || "sign.org.localhost"
  end

  test "should get edit raises error without session" do
    get edit_sign_org_configuration_out_url(ri: "jp"), headers: { "Host" => @host }

    rt = Base64.urlsafe_encode64(edit_sign_org_configuration_out_url(ri: "jp", host: @host))
    assert_redirected_to new_sign_org_in_url(rt: rt, host: @host)
  end

  test "should destroy raises error without session" do
    delete sign_org_configuration_out_url(ri: "jp"), headers: { "Host" => @host }

    rt = Base64.urlsafe_encode64(sign_org_configuration_out_url(ri: "jp", host: @host))
    assert_redirected_to new_sign_org_in_url(rt: rt, host: @host)
  end

  test "should destroy with staff session" do
    delete sign_org_configuration_out_url(ri: "jp"),
           headers: { "Host" => @host, "X-TEST-CURRENT-STAFF" => @staff.id }

    assert_redirected_to sign_org_root_path(ri: "jp")
  end
end
