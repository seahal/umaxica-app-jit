# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    require "test_helper"

    class Sign::Com::Configuration::SessionsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @host = ENV.fetch("IDENTITY_SIGN_COM_URL", "sign.com.localhost")
        host! @host

        @customer = create_verified_customer_with_email(email_address: "sessions-#{SecureRandom.hex(4)}@example.com")
        @customer.customer_telephones.create!(
          number: "+1555#{rand(1_000_000..9_999_999)}",
          customer_telephone_status_id: CustomerTelephoneStatus::VERIFIED,
        )
        @headers = as_customer_headers(@customer, host: @host)
        @token = CustomerToken.find_by!(public_id: @headers["X-TEST-SESSION-PUBLIC-ID"])
        satisfy_customer_verification(@token)
      end

      test "index returns active sessions as JSON" do
        get sign_com_configuration_sessions_url(ri: "jp", format: :json),
            headers: @headers.merge("Accept" => "application/json")

        assert_response :success
        assert_includes response.parsed_body["sessions"].pluck("public_id"), @token.public_id
      end

      test "destroy revokes other session and redirects with see_other" do
        other_token = CustomerToken.create!(customer: @customer, customer_token_kind_id: CustomerTokenKind::BROWSER_WEB)

        delete sign_com_configuration_session_url(other_token.public_id, ri: "jp"), headers: @headers

        assert_response :see_other
        other_token.reload

        assert_not_nil other_token.expired_at
      end

      test "destroy current session returns error redirect instead of revoking" do
        delete sign_com_configuration_session_url(@token.public_id, ri: "jp"), headers: @headers

        assert_response :redirect
        assert_match(/configuration\/sessions/, response.location)
        assert_nil @token.reload.expired_at
      end

      test "destroy non-existent session returns 404" do
        delete sign_com_configuration_session_url("missing_public_id", ri: "jp"), headers: @headers

        assert_response :not_found
      end

      test "others revokes other sessions and keeps current session active" do
        other_token = CustomerToken.create!(customer: @customer, customer_token_kind_id: CustomerTokenKind::BROWSER_WEB)

        delete identity.others_sign_com_configuration_sessions_url(ri: "jp"), headers: @headers

        assert_response :see_other
        assert_nil @token.reload.expired_at
        assert_not_nil other_token.reload.expired_at
      end

      test "others with no other sessions still succeeds" do
        delete identity.others_sign_com_configuration_sessions_url(ri: "jp"), headers: @headers

        assert_response :see_other
        assert_nil @token.reload.expired_at
      end

      test "others does not revoke already-revoked sessions" do
        other_token = CustomerToken.create!(customer: @customer, customer_token_kind_id: CustomerTokenKind::BROWSER_WEB)
        other_token.revoke!
        original_expired_at = other_token.reload.expired_at

        delete identity.others_sign_com_configuration_sessions_url(ri: "jp"), headers: @headers

        assert_response :see_other
        assert_equal original_expired_at.to_i, other_token.reload.expired_at.to_i
      end
    end
  end
end
