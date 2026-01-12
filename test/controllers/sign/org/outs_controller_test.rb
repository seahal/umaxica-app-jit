# frozen_string_literal: true

require "test_helper"

class Sign::Org::OutsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
    @host = ENV["SIGN_STAFF_URL"] || "sign.org.localhost"
  end

  test "should get edit raises error without session" do
    get edit_sign_org_out_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :not_found
  end

  test "should destroy raises error without session" do
    delete sign_org_out_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :not_found
  end

  test "should destroy with staff session" do
    get edit_sign_org_out_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :not_found
  end
end
