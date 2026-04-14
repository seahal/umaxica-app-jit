# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::Org::CoverageTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    host! @host

    @staff = staffs(:one)
    @headers = as_staff_headers(@staff, host: @host)
    @code_verifier = SecureRandom.urlsafe_base64(32)
    @code_challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(@code_verifier), padding: false)
    @client = Oidc::ClientRegistry.find("core_org")
    @redirect_uri = @client.redirect_uris.first
  end

  test "root renders" do
    get sign_org_root_url(ri: "jp")

    assert_response :success
  end

  test "configuration renders" do
    get sign_org_configuration_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "configuration challenges renders" do
    get sign_org_configuration_challenge_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "in challenges redirects without pending mfa" do
    get sign_org_in_challenge_url(ri: "jp"), headers: @headers

    assert_response :redirect
  end

  test "verification setup renders" do
    get new_sign_org_verification_setup_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "authorize redirects with code" do
    get sign_org_authorize_url(
      ri: "jp",
      response_type: "code",
      client_id: "core_org",
      redirect_uri: @redirect_uri,
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
      state: "test_state",
    ), headers: @headers

    assert_response :redirect
    uri = URI.parse(response.location)
    query = URI.decode_www_form(uri.query).to_h

    assert_predicate query["code"], :present?
    assert_equal "test_state", query["state"]
  end

  test "jwks returns JSON" do
    get sign_org_jwks_url(ri: "jp"), headers: browser_headers

    assert_response :success
    assert_kind_of Array, response.parsed_body["keys"]
  end

  test "up emails new renders for guests" do
    get new_sign_org_up_email_url(ri: "jp"), headers: browser_headers

    assert_response :success
  end
end
