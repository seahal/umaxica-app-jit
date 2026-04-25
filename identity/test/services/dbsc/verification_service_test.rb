# typed: false
# frozen_string_literal: true

require "test_helper"

class Dbsc::VerificationServiceTest < ActiveSupport::TestCase
  fixtures :users, :user_token_binding_methods, :user_token_dbsc_statuses, :user_tokens,
           :app_preference_binding_methods, :app_preference_dbsc_statuses, :app_preferences

  test "verifies proof and returns ok for active user token without changing status" do
    token = UserToken.create!(user: users(:one), refresh_expires_at: 1.day.from_now, deletable_at: 1.day.from_now)
    private_key = OpenSSL::PKey::EC.generate("prime256v1")

    token.update!(
      user_token_binding_method_id: UserTokenBindingMethod::DBSC,
      user_token_dbsc_status_id: UserTokenDbscStatus::ACTIVE,
      dbsc_session_id: "session-1",
      dbsc_public_key: { "kty" => "EC" },
      dbsc_challenge: "challenge-1",
      dbsc_challenge_issued_at: Time.current,
    )

    proof = JWT.encode(
      { "jti" => "challenge-1", "aud" => "https://test.host/verification", "iat" => Time.current.to_i },
      private_key, "ES256", { typ: "dbsc+jwt" },
    )

    Dbsc::RecordAdapter.stub(:dbsc_public_key, private_key.public_key) do
      result = Dbsc::VerificationService.call(
        record: token,
        session_id: "session-1",
        proof: proof,
      )

      assert result[:ok]
    end

    assert_equal UserTokenDbscStatus::ACTIVE, token.reload.user_token_dbsc_status_id
  end

  test "validates active app preference proof with current challenge" do
    preference = app_preferences(:one)
    private_key = OpenSSL::PKey::EC.generate("prime256v1")

    preference.update!(
      binding_method_id: AppPreferenceBindingMethod::DBSC,
      dbsc_status_id: AppPreferenceDbscStatus::ACTIVE,
      dbsc_session_id: "pref-session-1",
      dbsc_public_key: { "kty" => "EC" },
    )

    preference.update!(dbsc_challenge: "challenge-2", dbsc_challenge_issued_at: Time.current)
    proof = JWT.encode(
      { "jti" => "challenge-2", "aud" => "https://test.host/verification", "iat" => Time.current.to_i },
      private_key, "ES256", { typ: "dbsc+jwt" },
    )

    Dbsc::RecordAdapter.stub(:dbsc_public_key, private_key.public_key) do
      result = Dbsc::VerificationService.call(
        record: preference,
        session_id: "pref-session-1",
        proof: proof,
      )

      assert result[:ok]
    end
  end

  # -- Algorithm passthrough tests --

  test "rejects proof with HMAC confusion attack HS256" do
    token = UserToken.create!(user: users(:one), refresh_expires_at: 1.day.from_now, deletable_at: 1.day.from_now)
    private_key = OpenSSL::PKey::EC.generate("prime256v1")
    token.update!(
      user_token_binding_method_id: UserTokenBindingMethod::DBSC,
      user_token_dbsc_status_id: UserTokenDbscStatus::ACTIVE,
      dbsc_session_id: "session-hs256",
      dbsc_public_key: JWT::JWK.new(private_key).export,
      dbsc_challenge: "challenge-hs256",
      dbsc_challenge_issued_at: Time.current,
    )

    proof = JWT.encode(
      { "jti" => "challenge-hs256", "aud" => "https://test.host/verification", "iat" => Time.current.to_i },
      "any-secret", "HS256", { "typ" => "dbsc+jwt" },
    )

    result = Dbsc::VerificationService.call(record: token, session_id: "session-hs256", proof: proof)

    assert_not result[:ok]
  end

  test "rejects proof with ES384 algorithm not in DBSC whitelist" do
    token = UserToken.create!(user: users(:one), refresh_expires_at: 1.day.from_now, deletable_at: 1.day.from_now)
    private_key = OpenSSL::PKey::EC.generate("prime256v1")
    token.update!(
      user_token_binding_method_id: UserTokenBindingMethod::DBSC,
      user_token_dbsc_status_id: UserTokenDbscStatus::ACTIVE,
      dbsc_session_id: "session-es384",
      dbsc_public_key: JWT::JWK.new(private_key).export,
      dbsc_challenge: "challenge-es384",
      dbsc_challenge_issued_at: Time.current,
    )

    es384_key = OpenSSL::PKey::EC.generate("secp384r1")
    proof = JWT.encode(
      { "jti" => "challenge-es384", "aud" => "https://test.host/verification", "iat" => Time.current.to_i },
      es384_key, "ES384", { "typ" => "dbsc+jwt" },
    )

    result = Dbsc::VerificationService.call(record: token, session_id: "session-es384", proof: proof)

    assert_not result[:ok]
  end

  test "rejects proof with alg none header" do
    token = UserToken.create!(user: users(:one), refresh_expires_at: 1.day.from_now, deletable_at: 1.day.from_now)
    private_key = OpenSSL::PKey::EC.generate("prime256v1")
    token.update!(
      user_token_binding_method_id: UserTokenBindingMethod::DBSC,
      user_token_dbsc_status_id: UserTokenDbscStatus::ACTIVE,
      dbsc_session_id: "session-none",
      dbsc_public_key: JWT::JWK.new(private_key).export,
      dbsc_challenge: "challenge-none",
      dbsc_challenge_issued_at: Time.current,
    )

    proof = forge_jwt_with_header(
      { "alg" => "none", "typ" => "dbsc+jwt" },
      { "jti" => "challenge-none", "aud" => "https://test.host/verification", "iat" => Time.current.to_i },
    )

    result = Dbsc::VerificationService.call(record: token, session_id: "session-none", proof: proof)

    assert_not result[:ok]
  end

  test "rejects proof with alg empty string header" do
    token = UserToken.create!(user: users(:one), refresh_expires_at: 1.day.from_now, deletable_at: 1.day.from_now)
    private_key = OpenSSL::PKey::EC.generate("prime256v1")
    token.update!(
      user_token_binding_method_id: UserTokenBindingMethod::DBSC,
      user_token_dbsc_status_id: UserTokenDbscStatus::ACTIVE,
      dbsc_session_id: "session-empty",
      dbsc_public_key: JWT::JWK.new(private_key).export,
      dbsc_challenge: "challenge-empty",
      dbsc_challenge_issued_at: Time.current,
    )

    proof = forge_jwt_with_header(
      { "alg" => "", "typ" => "dbsc+jwt" },
      { "jti" => "challenge-empty", "aud" => "https://test.host/verification", "iat" => Time.current.to_i },
    )

    result = Dbsc::VerificationService.call(record: token, session_id: "session-empty", proof: proof)

    assert_not result[:ok]
  end

  test "rejects proof with alg nil header" do
    token = UserToken.create!(user: users(:one), refresh_expires_at: 1.day.from_now, deletable_at: 1.day.from_now)
    private_key = OpenSSL::PKey::EC.generate("prime256v1")
    token.update!(
      user_token_binding_method_id: UserTokenBindingMethod::DBSC,
      user_token_dbsc_status_id: UserTokenDbscStatus::ACTIVE,
      dbsc_session_id: "session-nil",
      dbsc_public_key: JWT::JWK.new(private_key).export,
      dbsc_challenge: "challenge-nil",
      dbsc_challenge_issued_at: Time.current,
    )

    proof = forge_jwt_with_header(
      { "alg" => nil, "typ" => "dbsc+jwt" },
      { "jti" => "challenge-nil", "aud" => "https://test.host/verification", "iat" => Time.current.to_i },
    )

    result = Dbsc::VerificationService.call(record: token, session_id: "session-nil", proof: proof)

    assert_not result[:ok]
  end

  private

  def forge_jwt_with_header(header_hash, payload_hash)
    header = Base64.urlsafe_encode64(JSON.generate(header_hash), padding: false)
    payload = Base64.urlsafe_encode64(JSON.generate(payload_hash), padding: false)
    "#{header}.#{payload}."
  end
end
