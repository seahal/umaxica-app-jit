# frozen_string_literal: true

require "test_helper"

class Sign::App::InsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
  end

  test "should get new with authentication links" do
    get new_sign_app_in_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :success

    query = {}
    assert_select "a[href=?]", new_sign_app_in_email_path(query, ri: "jp"),
                  I18n.t("sign.app.authentication.new.links.email")
    assert_select "a[href=?]", new_sign_app_in_passkey_path(query, ri: "jp"),
                  I18n.t("sign.app.authentication.new.links.passkey")
    assert_select "a[href=?]", new_sign_app_in_secret_path(query, ri: "jp"),
                  I18n.t("sign.app.authentication.new.links.secret")
  end

  test "should render in english when lx=en" do
    get new_sign_app_in_url(lx: "en", ri: "jp"), headers: { "Host" => @host }
    assert_response :success
    assert_select "html[lang=en]"
    assert_select "a", text: "Sign Up"
  end
end
