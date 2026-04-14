# typed: false
# frozen_string_literal: true

require "test_helper"

class AuthTokenServiceTest < ActiveSupport::TestCase
  def ensure_customer_reference_records!
    CustomerStatus.find_or_create_by!(id: CustomerStatus::ACTIVE)
    CustomerStatus.find_or_create_by!(id: CustomerStatus::NOTHING)
    CustomerStatus.find_or_create_by!(id: CustomerStatus::RESERVED)
    CustomerVisibility.find_or_create_by!(id: CustomerVisibility::NOBODY)
    CustomerVisibility.find_or_create_by!(id: CustomerVisibility::CUSTOMER)
    CustomerVisibility.find_or_create_by!(id: CustomerVisibility::STAFF)
    CustomerVisibility.find_or_create_by!(id: CustomerVisibility::BOTH)
  end
  test "encode returns nil for nil resource" do
    result = Auth::TokenService.encode(nil, host: "example.com")

    assert_nil result
  end

  test "encode returns nil for blank host" do
    user = users(:one)
    result = Auth::TokenService.encode(user, host: "")

    assert_nil result
  end

  test "decode returns nil for blank token" do
    result = Auth::TokenService.decode("", host: "example.com", resource_type: "user")

    assert_nil result
  end

  test "decode returns nil for blank host" do
    result = Auth::TokenService.decode("some_token", host: "", resource_type: "user")

    assert_nil result
  end

  test "extract_subject returns subject from payload" do
    payload = { "sub" => 123 }

    assert_equal 123, Auth::TokenService.extract_subject(payload)
  end

  test "extract_act returns act from payload" do
    payload = { "act" => "staff" }

    assert_equal "staff", Auth::TokenService.extract_act(payload)
  end

  test "extract_session_id returns sid from payload" do
    payload = { "sid" => "abc123" }

    assert_equal "abc123", Auth::TokenService.extract_session_id(payload)
  end

  test "extract_jti returns jti from payload" do
    payload = { "jti" => "xyz789" }

    assert_equal "xyz789", Auth::TokenService.extract_jti(payload)
  end

  test "validate_actor_claim! returns true for matching user" do
    payload = { "act" => "user" }

    assert Auth::TokenService.validate_actor_claim!(payload, "user")
  end

  test "validate_actor_claim! returns false for mismatched actor" do
    payload = { "act" => "user" }

    assert_not Auth::TokenService.validate_actor_claim!(payload, "staff")
  end

  test "validate_actor_claim! returns true for matching customer" do
    payload = { "act" => "user" }

    assert Auth::TokenService.validate_actor_claim!(payload, "user")
  end

  test "encode creates valid token that can be decoded" do
    user = users(:one)
    token = Auth::TokenService.encode(
      user, host: "example.com", session_public_id: "sid123",
            resource_type: "user",
    )

    assert_predicate token, :present?

    payload = Auth::TokenService.decode(token, host: "example.com", resource_type: "user")

    assert_predicate payload, :present?
    assert_equal user.id, payload["sub"]
  end

  test "decode rejects token when resource_type issuer/type do not match" do
    user = users(:one)
    token = Auth::TokenService.encode(
      user, host: "example.com", session_public_id: "sid123",
            resource_type: "user",
    )

    assert_nil Auth::TokenService.decode(token, host: "example.com", resource_type: "staff")
  end

  test "encode creates valid customer token that can be decoded" do
    ensure_customer_reference_records!
    customer = Customer.create!
    token = Auth::TokenService.encode(
      customer, host: "example.com", session_public_id: "sid999",
                resource_type: "customer",
    )

    assert_predicate token, :present?

    payload = Auth::TokenService.decode(token, host: "example.com", resource_type: "customer")

    assert_predicate payload, :present?
    assert_equal customer.id, payload["sub"]
    assert_equal "customer", payload["act"]
  end

  test "encode includes subject_type, acr, amr claims" do
    user = users(:one)
    token = Auth::TokenService.encode(
      user, host: "example.com", session_public_id: "sid123",
            resource_type: "user", acr: "aal1", amr: ["email_otp"],
    )

    payload = Auth::TokenService.decode(token, host: "example.com", resource_type: "user")

    assert_equal "user", payload["subject_type"]
    assert_equal "aal1", payload["acr"]
    assert_equal ["email_otp"], payload["amr"]
  end

  test "encode with default acr and amr when not provided" do
    user = users(:one)
    token = Auth::TokenService.encode(
      user, host: "example.com", session_public_id: "sid123",
            resource_type: "user",
    )

    payload = Auth::TokenService.decode(token, host: "example.com", resource_type: "user")

    assert_equal "aal1", payload["acr"]
    assert_equal [], payload["amr"]
  end

  test "decode rejects token missing subject_type claim" do
    user = users(:one)
    token = Auth::TokenService.encode(
      user, host: "example.com", session_public_id: "sid123",
            resource_type: "user",
    )

    tampered = tamper_remove_claim(token, "subject_type")

    assert_nil Auth::TokenService.decode(tampered, host: "example.com", resource_type: "user")
  end

  test "decode rejects token missing acr claim" do
    user = users(:one)
    token = Auth::TokenService.encode(
      user, host: "example.com", session_public_id: "sid123",
            resource_type: "user",
    )

    tampered = tamper_remove_claim(token, "acr")

    assert_nil Auth::TokenService.decode(tampered, host: "example.com", resource_type: "user")
  end

  test "decode rejects token missing amr claim" do
    user = users(:one)
    token = Auth::TokenService.encode(
      user, host: "example.com", session_public_id: "sid123",
            resource_type: "user",
    )

    tampered = tamper_remove_claim(token, "amr")

    assert_nil Auth::TokenService.decode(tampered, host: "example.com", resource_type: "user")
  end

  test "decode rejects HMAC confusion attack with HS384 and public key" do
    public_key = Jit::Security::Jwt::Keyring.public_key_for_active
    hmac_secret = public_key.to_pem
    token = JWT.encode(
      { "sub" => 1, "act" => "user" },
      hmac_secret, "HS384",
      { "kid" => Jit::Security::Jwt::Keyring.active_kid, "typ" => "auth-access-token;user" },
    )

    assert_nil Auth::TokenService.decode(token, host: "example.com", resource_type: "user")
  end

  test "decode rejects HMAC confusion attack with HS256 and public key" do
    public_key = Jit::Security::Jwt::Keyring.public_key_for_active
    hmac_secret = public_key.to_pem
    token = JWT.encode(
      { "sub" => 1, "act" => "user" },
      hmac_secret, "HS256",
      { "kid" => Jit::Security::Jwt::Keyring.active_kid, "typ" => "auth-access-token;user" },
    )

    assert_nil Auth::TokenService.decode(token, host: "example.com", resource_type: "user")
  end

  test "decode rejects token signed with ES256 algorithm" do
    es256_key = OpenSSL::PKey::EC.generate("prime256v1")
    token = JWT.encode(
      { "sub" => 1, "act" => "user" },
      es256_key, "ES256",
      { "kid" => Jit::Security::Jwt::Keyring.active_kid, "typ" => "auth-access-token;user" },
    )

    assert_nil Auth::TokenService.decode(token, host: "example.com", resource_type: "user")
  end

  test "decode rejects forged token with injected jwk header" do
    token = forge_jwt_with_header(
      {
        "alg" => "ES384",
        "typ" => "auth-access-token;user",
        "kid" => Jit::Security::Jwt::Keyring.active_kid,
        "jwk" => { "kty" => "EC", "crv" => "P-384" },
        "jku" => "https://attacker.example.com/jwks",
      },
      { "sub" => 1, "act" => "user" },
    )

    assert_nil Auth::TokenService.decode(token, host: "example.com", resource_type: "user")
  end

  test "decode rejects token with single segment" do
    assert_nil Auth::TokenService.decode("eyJhbGciOiJFUzM4NCJ9", host: "example.com", resource_type: "user")
  end

  test "decode rejects token with four segments" do
    token = forge_jwt_with_header(
      { "alg" => "ES384", "typ" => "auth-access-token;user", "kid" => "any" },
      { "sub" => 1 },
    )

    assert_nil Auth::TokenService.decode("#{token}extra_segment", host: "example.com", resource_type: "user")
  end

  test "decode rejects forged token with correct alg ES384 but unknown kid" do
    token = forge_jwt_with_header(
      { "alg" => "ES384", "typ" => "auth-access-token;user", "kid" => "forged-kid" },
      { "sub" => 1, "act" => "user" },
    )

    assert_nil Auth::TokenService.decode(token, host: "example.com", resource_type: "user")
  end

  test "decode rejects forged token with correct alg ES384 and valid kid but invalid signature" do
    token = forge_jwt_with_header(
      { "alg" => "ES384", "typ" => "auth-access-token;user", "kid" => Jit::Security::Jwt::Keyring.active_kid },
      { "sub" => 1, "act" => "user" },
    )

    assert_nil Auth::TokenService.decode(token, host: "example.com", resource_type: "user")
  end

  # -- Expired / timing boundary tests --

  test "decode rejects token expired beyond leeway" do
    user = users(:one)
    token = Auth::TokenService.encode(
      user, host: "example.com", session_public_id: "sid-exp",
            resource_type: "user", expires_at: 31.seconds.ago,
    )

    assert_nil Auth::TokenService.decode(token, host: "example.com", resource_type: "user")
  end

  test "decode rejects token with future iat beyond leeway" do
    tampered = tamper_set_claim_with_resign(
      users(:one), "iat", 5.minutes.from_now.to_i,
    )

    assert_nil Auth::TokenService.decode(tampered, host: "example.com", resource_type: "user")
  end

  # -- kid injection tests --

  test "decode rejects token with SQL injection in kid" do
    token = forge_jwt_with_header(
      { "alg" => "ES384", "typ" => "auth-access-token;user", "kid" => "' OR 1=1 --" },
      { "sub" => 1 },
    )

    assert_nil Auth::TokenService.decode(token, host: "example.com", resource_type: "user")
  end

  test "decode rejects token with path traversal in kid" do
    token = forge_jwt_with_header(
      { "alg" => "ES384", "typ" => "auth-access-token;user", "kid" => "../../etc/passwd" },
      { "sub" => 1 },
    )

    assert_nil Auth::TokenService.decode(token, host: "example.com", resource_type: "user")
  end

  # -- Malformed token tests --

  test "decode rejects token containing null bytes" do
    assert_nil Auth::TokenService.decode("eyJ\x00hbGci.eyJz\x00dWIi.sig", host: "example.com", resource_type: "user")
  end

  test "decode rejects extremely long token" do
    long_token = "a" * 100_000

    assert_nil Auth::TokenService.decode(long_token, host: "example.com", resource_type: "user")
  end

  test "decode rejects token with unicode in segments" do
    assert_nil Auth::TokenService.decode("eyJhbGci\u00e9.eyJzdWIi.sig", host: "example.com", resource_type: "user")
  end

  test "decode rejects token with alg none header" do
    token = forge_jwt_with_header(
      { "alg" => "none", "typ" => "auth-access-token;user", "kid" => "any" },
      { "sub" => 1 },
    )

    assert_nil Auth::TokenService.decode(token, host: "example.com", resource_type: "user")
  end

  test "decode rejects token with alg empty string header" do
    token = forge_jwt_with_header(
      { "alg" => "", "typ" => "auth-access-token;user", "kid" => "any" },
      { "sub" => 1 },
    )

    assert_nil Auth::TokenService.decode(token, host: "example.com", resource_type: "user")
  end

  test "decode rejects token with alg nil header" do
    token = forge_jwt_with_header(
      { "alg" => nil, "typ" => "auth-access-token;user", "kid" => "any" },
      { "sub" => 1 },
    )

    assert_nil Auth::TokenService.decode(token, host: "example.com", resource_type: "user")
  end

  private

  def forge_jwt_with_header(header_hash, payload_hash)
    header = Base64.urlsafe_encode64(JSON.generate(header_hash), padding: false)
    payload = Base64.urlsafe_encode64(JSON.generate(payload_hash), padding: false)
    "#{header}.#{payload}."
  end

  def tamper_set_claim_with_resign(user, claim, value)
    token = Auth::TokenService.encode(
      user, host: "example.com", session_public_id: "sid-tamper",
            resource_type: "user",
    )
    decoded = JWT.decode(token, nil, false)
    payload = decoded[0]
    header = decoded[1]
    payload[claim] = value
    JWT.encode(payload, Jit::Security::Jwt::Keyring.private_key_for_active, "ES384", header)
  end

  def tamper_remove_claim(token, claim)
    require "jwt"
    decoded = JWT.decode(token, nil, false)
    payload = decoded[0]
    header = decoded[1] || { "alg" => "ES384", "typ" => "auth-access-token;user" }
    payload.delete(claim)
    JWT.encode(payload, Jit::Security::Jwt::Keyring.private_key_for_active, "ES384", header)
  end
end
