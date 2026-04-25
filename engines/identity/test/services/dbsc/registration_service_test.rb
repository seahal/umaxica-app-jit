# typed: false
# frozen_string_literal: true

require "test_helper"

class Dbsc::RegistrationServiceTest < ActiveSupport::TestCase
  fixtures :users, :user_token_binding_methods, :user_token_dbsc_statuses, :user_tokens,
           :app_preference_binding_methods, :app_preference_dbsc_statuses, :app_preferences

  test "sets user token to active dbsc state" do
    token = UserToken.create!(user: users(:one), refresh_expires_at: 1.day.from_now, deletable_at: 1.day.from_now)
    token.update!(dbsc_challenge: "challenge-1", dbsc_challenge_issued_at: Time.current)
    private_key = OpenSSL::PKey::EC.generate("prime256v1")
    public_jwk = JWT::JWK.new(private_key).export

    proof = JWT.encode(
      { "jti" => "challenge-1", "aud" => "https://test.host/registration", "iat" => Time.current.to_i },
      private_key, "ES256", { typ: "dbsc+jwt", jwk: public_jwk },
    )

    result = Dbsc::RegistrationService.call(record: token, proof: proof, session_id: "dbsc-session-1")

    assert_predicate result[:ok], :present?

    token.reload

    assert_equal UserTokenBindingMethod::DBSC, token.user_token_binding_method_id
    assert_equal UserTokenDbscStatus::ACTIVE, token.user_token_dbsc_status_id
    assert_equal "dbsc-session-1", token.dbsc_session_id
    assert_equal public_jwk.stringify_keys, token.dbsc_public_key
    assert_nil token.dbsc_challenge
  end

  test "sets app preference to active dbsc state" do
    preference = app_preferences(:one)
    preference.update!(dbsc_challenge: "challenge-2", dbsc_challenge_issued_at: Time.current)
    private_key = OpenSSL::PKey::EC.generate("prime256v1")
    public_jwk = JWT::JWK.new(private_key).export

    proof = JWT.encode(
      { "jti" => "challenge-2", "aud" => "https://test.host/registration", "iat" => Time.current.to_i },
      private_key, "ES256", { typ: "dbsc+jwt", jwk: public_jwk },
    )

    result = Dbsc::RegistrationService.call(record: preference, proof: proof, session_id: "dbsc-pref-1")

    assert_predicate result[:ok], :present?

    preference.reload

    assert_equal AppPreferenceBindingMethod::DBSC, preference.binding_method_id
    assert_equal AppPreferenceDbscStatus::ACTIVE, preference.dbsc_status_id
    assert_equal "dbsc-pref-1", preference.dbsc_session_id
    assert_equal public_jwk.stringify_keys, preference.dbsc_public_key
    assert_nil preference.dbsc_challenge
  end

  test "returns challenge_expired when dbsc_challenge_issued_at is too old" do
    token = UserToken.create!(user: users(:one), refresh_expires_at: 1.day.from_now, deletable_at: 1.day.from_now)
    token.update!(dbsc_challenge: "old-challenge", dbsc_challenge_issued_at: 10.minutes.ago)
    private_key = OpenSSL::PKey::EC.generate("prime256v1")
    public_jwk = JWT::JWK.new(private_key).export

    proof = JWT.encode(
      { "jti" => "old-challenge", "aud" => "https://test.host/registration", "iat" => Time.current.to_i },
      private_key, "ES256", { typ: "dbsc+jwt", jwk: public_jwk },
    )

    result = Dbsc::RegistrationService.call(record: token, proof: proof, session_id: "dbsc-session-x")

    assert_not result[:ok]
    assert_equal "challenge_expired", result[:error_code]
  end

  test "returns challenge_expired when dbsc_challenge_issued_at is blank" do
    token = UserToken.create!(user: users(:one), refresh_expires_at: 1.day.from_now, deletable_at: 1.day.from_now)
    token.update!(dbsc_challenge: "stale-challenge", dbsc_challenge_issued_at: nil)
    private_key = OpenSSL::PKey::EC.generate("prime256v1")
    public_jwk = JWT::JWK.new(private_key).export

    proof = JWT.encode(
      { "jti" => "stale-challenge", "aud" => "https://test.host/registration", "iat" => Time.current.to_i },
      private_key, "ES256", { typ: "dbsc+jwt", jwk: public_jwk },
    )

    result = Dbsc::RegistrationService.call(record: token, proof: proof, session_id: "dbsc-session-y")

    assert_not result[:ok]
    assert_equal "challenge_expired", result[:error_code]
  end

  # -- Algorithm passthrough tests (user-controlled alg reaches JWT.decode) --

  test "rejects proof with HMAC confusion attack HS256" do
    token = UserToken.create!(user: users(:one), refresh_expires_at: 1.day.from_now, deletable_at: 1.day.from_now)
    token.update!(dbsc_challenge: "challenge-hs256", dbsc_challenge_issued_at: Time.current)

    proof = JWT.encode(
      { "jti" => "challenge-hs256", "aud" => "https://test.host/registration", "iat" => Time.current.to_i },
      "any-secret", "HS256", { "typ" => "dbsc+jwt" },
    )

    result = Dbsc::RegistrationService.call(record: token, proof: proof, session_id: "dbsc-hs256")

    assert_not result[:ok]
  end

  test "rejects proof with ES384 algorithm not in DBSC whitelist" do
    token = UserToken.create!(user: users(:one), refresh_expires_at: 1.day.from_now, deletable_at: 1.day.from_now)
    token.update!(dbsc_challenge: "challenge-es384", dbsc_challenge_issued_at: Time.current)

    es384_key = OpenSSL::PKey::EC.generate("secp384r1")
    proof = JWT.encode(
      { "jti" => "challenge-es384", "aud" => "https://test.host/registration", "iat" => Time.current.to_i },
      es384_key, "ES384", { "typ" => "dbsc+jwt" },
    )

    result = Dbsc::RegistrationService.call(record: token, proof: proof, session_id: "dbsc-es384")

    assert_not result[:ok]
  end

  test "rejects proof with alg none header" do
    token = UserToken.create!(user: users(:one), refresh_expires_at: 1.day.from_now, deletable_at: 1.day.from_now)
    token.update!(dbsc_challenge: "challenge-none", dbsc_challenge_issued_at: Time.current)

    proof = forge_jwt_with_header(
      { "alg" => "none", "typ" => "dbsc+jwt" },
      { "jti" => "challenge-none", "aud" => "https://test.host/registration", "iat" => Time.current.to_i },
    )

    result = Dbsc::RegistrationService.call(record: token, proof: proof, session_id: "dbsc-none")

    assert_not result[:ok]
  end

  test "rejects proof with alg empty string header" do
    token = UserToken.create!(user: users(:one), refresh_expires_at: 1.day.from_now, deletable_at: 1.day.from_now)
    token.update!(dbsc_challenge: "challenge-empty", dbsc_challenge_issued_at: Time.current)

    proof = forge_jwt_with_header(
      { "alg" => "", "typ" => "dbsc+jwt" },
      { "jti" => "challenge-empty", "aud" => "https://test.host/registration", "iat" => Time.current.to_i },
    )

    result = Dbsc::RegistrationService.call(record: token, proof: proof, session_id: "dbsc-empty")

    assert_not result[:ok]
  end

  test "rejects proof with alg nil header" do
    token = UserToken.create!(user: users(:one), refresh_expires_at: 1.day.from_now, deletable_at: 1.day.from_now)
    token.update!(dbsc_challenge: "challenge-nil", dbsc_challenge_issued_at: Time.current)

    proof = forge_jwt_with_header(
      { "alg" => nil, "typ" => "dbsc+jwt" },
      { "jti" => "challenge-nil", "aud" => "https://test.host/registration", "iat" => Time.current.to_i },
    )

    result = Dbsc::RegistrationService.call(record: token, proof: proof, session_id: "dbsc-nil")

    assert_not result[:ok]
  end

  private

  def forge_jwt_with_header(header_hash, payload_hash)
    header = Base64.urlsafe_encode64(JSON.generate(header_hash), padding: false)
    payload = Base64.urlsafe_encode64(JSON.generate(payload_hash), padding: false)
    "#{header}.#{payload}."
  end
end
