# typed: false
# frozen_string_literal: true

require "test_helper"

class Dbsc::RegistrationServiceTest < ActiveSupport::TestCase
  fixtures :users, :user_token_binding_methods, :user_token_dbsc_statuses, :user_tokens,
           :app_preference_binding_methods, :app_preference_dbsc_statuses, :app_preferences

  test "sets user token to pending dbsc state" do
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

  test "sets app preference to pending dbsc state" do
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
end
