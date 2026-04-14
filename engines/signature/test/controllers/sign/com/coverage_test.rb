# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::Com::CoverageTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost")
    host! @host

    @customer = create_verified_customer_with_email(email_address: "sign-com-#{SecureRandom.hex(4)}@example.com")
    @customer.customer_telephones.create!(
      number: "+8190#{SecureRandom.random_number(10**8).to_s.rjust(8, "0")}",
      customer_telephone_status_id: CustomerTelephoneStatus::VERIFIED,
    )
    @headers = as_customer_headers(@customer, host: @host)
    @token = CustomerToken.find_by!(public_id: @headers["X-TEST-SESSION-PUBLIC-ID"])
    satisfy_customer_verification(@token)

    @code_verifier = SecureRandom.urlsafe_base64(32)
    @code_challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(@code_verifier), padding: false)
    @client = Oidc::ClientRegistry.find("core_com")
    @redirect_uri = @client.redirect_uris.first
  end

  test "root renders" do
    get sign_com_root_url(ri: "jp")

    assert_response :success
  end

  test "configuration renders" do
    get sign_com_configuration_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "configuration edit redirects" do
    get edit_sign_com_configuration_url(ri: "jp"), headers: @headers

    assert_response :redirect
  end

  test "configuration activities renders" do
    get sign_com_configuration_activities_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "configuration challenges renders" do
    get sign_com_configuration_challenge_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "configuration sessions renders" do
    get sign_com_configuration_sessions_url(ri: "jp", format: :json),
        headers: @headers.merge("Accept" => "application/json")

    assert_response :success
    assert_kind_of Array, response.parsed_body["sessions"]
  end

  test "configuration secrets renders" do
    get sign_com_configuration_secrets_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "configuration outs edit renders" do
    get edit_sign_com_configuration_out_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "verification setup renders" do
    get new_sign_com_verification_setup_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "authorize redirects with code" do
    get sign_com_authorize_url(
      response_type: "code",
      client_id: "core_com",
      redirect_uri: @redirect_uri,
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
      state: "test_state",
    ), headers: @headers

    assert_response :redirect
    assert_predicate response.location, :present?
  end

  test "jwks returns JSON" do
    get sign_com_jwks_url(ri: "jp"), headers: browser_headers

    assert_response :success
    assert_kind_of Array, response.parsed_body["keys"]
  end

  test "up new renders for guests" do
    get new_sign_com_up_url(ri: "jp"), headers: browser_headers

    assert_response :success
  end

  test "in bulletin renders" do
    get sign_com_in_bulletin_url(ri: "jp"),
        headers: browser_headers.merge("X-TEST-BULLETIN" => bulletin_json)

    assert_response :success
  end

  test "web email otp responds" do
    post sign_com_web_v0_in_email_otp_path,
         params: { state: otp_state(kind: :email, target: @customer.customer_emails.first.address) },
         headers: { "Host" => @host },
         as: :json

    assert_response :success
  end

  test "web telephone otp responds" do
    post sign_com_web_v0_in_telephone_otp_path,
         params: { state: otp_state(kind: :telephone, target: @customer.customer_telephones.first.number) },
         headers: { "Host" => @host },
         as: :json

    assert_response :success
  end

  private

  def otp_state(kind:, target:)
    Sign::In::OtpResendState.issue(kind: kind, target: target)
  end

  def bulletin_json
    { "issued_at" => Time.current.to_i, "kind" => "mock", "state" => "new" }.to_json
  end
end
