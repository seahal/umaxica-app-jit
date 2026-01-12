# frozen_string_literal: true

require "test_helper"

class Sign::App::OutsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end

  test "should get edit raises error without session" do
    get edit_sign_app_out_url(ri: "jp"), headers: { "Host" => @host }
    assert_response :not_found
  end

  test "should destroy raises error without session" do
    delete sign_app_out_url(ri: "jp"), headers: { "Host" => @host }
    assert_response :not_found
  end
end
