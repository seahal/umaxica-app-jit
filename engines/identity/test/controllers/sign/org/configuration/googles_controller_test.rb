# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    require "test_helper"
    require "base64"

    class Sign::Org::Configuration::GooglesControllerTest < ActionDispatch::IntegrationTest
      fixtures :staffs, :staff_statuses

      setup do
        host! ENV.fetch("IDENTITY_SIGN_ORG_URL", "sign.org.localhost")
        @host = ENV.fetch("IDENTITY_SIGN_ORG_URL", "sign.org.localhost")
        @staff = staffs(:one)
        @headers = { "Host" => @host, "X-TEST-CURRENT-STAFF" => @staff.id }.freeze
      end

      test "should get show when logged in" do
        get sign_org_configuration_google_url(ri: "jp"), headers: @headers

        assert_response :success
      end

      test "create redirects to google social session" do
        post sign_org_configuration_google_url(ri: "jp"), headers: @headers

        assert_redirected_to new_sign_org_social_session_url(provider: "google_org", ri: "jp")
      end

      test "should redirect show when not logged in" do
        get sign_org_configuration_google_url(ri: "jp")
        rt = Base64.strict_encode64(sign_org_configuration_google_url(ri: "jp"))

        assert_redirected_to new_sign_org_in_url(rt: rt, host: @host)
      end
    end
  end
end
