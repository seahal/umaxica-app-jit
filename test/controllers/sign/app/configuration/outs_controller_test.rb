# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::OutsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end

  test "should get edit raises error without session" do
    get edit_sign_app_configuration_out_url(ri: "jp"), headers: { "Host" => @host }

    rt = Base64.urlsafe_encode64(edit_sign_app_configuration_out_url(ri: "jp", host: @host))
    assert_redirected_to new_sign_app_in_url(rt: rt, host: @host)
  end

  test "should show up link on edit page" do
    get edit_sign_app_configuration_out_url(ri: "jp"),
        headers: { "Host" => @host, "X-TEST-CURRENT-USER" => @user.id }

    assert_response :success
    assert_select "a[href=?]", sign_app_configuration_path(ri: "jp")
  end

  test "should destroy raises error without session" do
    delete sign_app_configuration_out_url(ri: "jp"), headers: { "Host" => @host }

    rt = Base64.urlsafe_encode64(sign_app_configuration_out_url(ri: "jp", host: @host))
    assert_redirected_to new_sign_app_in_url(rt: rt, host: @host)
  end

  test "should destroy with user session" do
    delete sign_app_configuration_out_url(ri: "jp"),
           headers: { "Host" => @host, "X-TEST-CURRENT-USER" => @user.id }

    assert_redirected_to sign_app_root_path(ri: "jp")
    assert_equal I18n.t("sign.shared.sign_out.success"), flash[:notice]
  end
end
