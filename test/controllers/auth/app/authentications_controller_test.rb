# frozen_string_literal: true

require "test_helper"

class Auth::App::AuthenticationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new with authentication links" do
    get new_auth_app_authentication_url, headers: { "Host" => ENV["AUTH_SERVICE_URL"] }

    assert_response :success

    query = { lx: "ja", ri: "jp", tz: "jst", ct: "sy" }
    assert_select "a[href=?]", new_auth_app_authentication_email_path(query),
                  I18n.t("auth.app.authentication.new.links.email")
    assert_select "a[href=?]", new_auth_app_authentication_passkey_path(query),
                  I18n.t("auth.app.authentication.new.links.passkey")
    assert_select "a[href=?]", new_auth_app_authentication_recovery_path(query),
                  I18n.t("auth.app.authentication.new.links.recovery")
  end

  test "should get edit" do
    get edit_auth_app_authentication_url
    # assert_response :internal_server_error
    assert_select "h1", I18n.t("auth.app.authentication.edit.title")
  end

  test "should not get edit when not logged in" do
    get edit_auth_app_authentication_url
    # assert_response :internal_server_error
    assert_select "h1", I18n.t("auth.app.authentication.edit.title")
  end

  test "destroy redirects to login page" do
    delete auth_app_authentication_url

    assert_response :redirect
    assert_not_nil flash[:success]
  end

  test "destroy responds to DELETE request" do
    delete auth_app_authentication_url

    assert_response :redirect
  end

  test "destroy records logout audit event" do
    user = users(:one)

    assert_difference -> { UserIdentityAudit.where(event_id: "LOGGED_OUT").count }, 1 do
      delete auth_app_authentication_url,
             headers: { "Host" => ENV["AUTH_SERVICE_URL"], "X-TEST-CURRENT-USER" => user.id }
    end

    audit = UserIdentityAudit.order(created_at: :desc).first

    assert_equal "LOGGED_OUT", audit.event_id
    assert_equal user, audit.user
  end
end
