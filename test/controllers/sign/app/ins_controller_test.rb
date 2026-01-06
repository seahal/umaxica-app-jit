# frozen_string_literal: true

require "test_helper"

class Sign::App::InsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
  end

  test "should get new with authentication links" do
    get new_sign_app_in_url, headers: { "Host" => @host }

    assert_response :success

    query = { lx: "ja", ri: "jp", tz: "jst", ct: "sy" }
    assert_select "a[href=?]", new_sign_app_in_email_path(query),
                  I18n.t("sign.app.authentication.new.links.email")
    assert_select "a[href=?]", new_sign_app_in_passkey_path(query),
                  I18n.t("sign.app.authentication.new.links.passkey")
    assert_select "a[href=?]", new_sign_app_in_secret_path(query),
                  I18n.t("sign.app.authentication.new.links.secret")
    assert_select "a[href=?]", sign_app_root_path(query),
                  I18n.t("sign.app.authentication.new.back_link")
  end
end
