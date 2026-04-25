# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    require "test_helper"
    require "base64"

    class Jit::Foundation::Base::App::Configuration::EmailsControllerTest < ActionDispatch::IntegrationTest
      fixtures :users, :user_statuses

      setup do
        host! ENV.fetch("FOUNDATION_BASE_APP_URL", "base.app.localhost")
        @user = users(:one)
        @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze
      end

      test "should get new when logged in" do
        get base_, headers: @headers

        assert_response :success
      end

      test "should redirect new when not logged in" do
        get base_(ri: "jp")

        # First redirect: canonicalize_regional_params removes ri param
        assert_response :redirect
        follow_redirect!

        # Second redirect: auth_required redirects to login
        rt = Base64.urlsafe_encode64(base_)

        assert_redirected_to identity.new_sign_app_in_url(rt: rt, host: "sign.app.localhost")
        assert_equal I18n.t("errors.messages.login_required"), flash[:alert]
      end

      test "should redirect create when not logged in" do
        post foundation.base_app_configuration_emails_url(ri: "jp")

        # First redirect: canonicalize_regional_params removes ri param
        assert_response :redirect
        follow_redirect!

        # Second redirect: auth_required redirects to login
        # Note: ri is added back via default_url_options
        rt = Base64.urlsafe_encode64(foundation.base_app_configuration_emails_url(ri: "jp"))

        assert_redirected_to identity.new_sign_app_in_url(rt: rt, ri: "jp", host: "sign.app.localhost")
      end
    end

    class Jit::Foundation::Base::Org::Configuration::EmailsControllerTest < ActionDispatch::IntegrationTest
      fixtures :staffs, :staff_statuses

      setup do
        @host = ENV.fetch("FOUNDATION_BASE_ORG_URL", "base.org.localhost")
        @sign_host = ENV.fetch("IDENTITY_SIGN_ORG_URL", "sign.org.localhost")
        host! @host
        @staff = staffs(:one)
        @headers = { "X-TEST-CURRENT-STAFF" => @staff.id }.freeze
      end

      test "should get new when logged in" do
        get new_base_org_configuration_email_url, headers: @headers

        assert_response :success
      end

      test "should redirect new when not logged in" do
        get new_base_org_configuration_email_url(ri: "jp")

        # First redirect: canonicalize_regional_params removes ri param
        assert_response :redirect
        follow_redirect!

        # Second redirect: auth_required redirects to login
        rt = Base64.urlsafe_encode64(new_base_org_configuration_email_url)

        assert_redirected_to identity.new_sign_org_in_url(rt: rt, host: @sign_host)
        assert_equal I18n.t("errors.messages.login_required"), flash[:alert]
      end

      test "should redirect create when not logged in" do
        post foundation.base_org_configuration_emails_url(ri: "jp")

        # First redirect: canonicalize_regional_params removes ri param
        assert_response :redirect
        follow_redirect!

        # Second redirect: auth_required redirects to login
        # Note: ri is added back via default_url_options
        rt = Base64.urlsafe_encode64(foundation.base_org_configuration_emails_url(ri: "jp"))

        assert_redirected_to identity.new_sign_org_in_url(rt: rt, ri: "jp", host: @sign_host)
      end
    end
  end
end
