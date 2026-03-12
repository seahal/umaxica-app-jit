# typed: false
# frozen_string_literal: true

require "test_helper"

module Auth
  class TokenClaimsTest < ActiveSupport::TestCase
    DummyResource = Struct.new(:id)

    test "build includes mandatory claims and optional sid" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "user",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
      )

      assert_equal 42, payload["sub"]
      assert_equal "user", payload["act"]
      assert_equal "sess_abc", payload["sid"]
      assert_equal issued_at.to_i, payload["iat"]
      assert_equal issued_at.to_i, payload["nbf"]
      assert_equal (issued_at + 10.minutes).to_i, payload["exp"]
      assert_equal "auth-access-token;user", payload["typ"]
      assert_equal Auth::Base::JwtConfiguration.issuer("user"), payload["iss"]
      assert_equal Auth::Base::JwtConfiguration.audiences("user"), payload["aud"]
      assert_predicate payload["jti"], :present?
    end

    test "build uses explicit expires_at when provided" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      expires_at = issued_at + 5.minutes
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "user",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
        expires_at: expires_at,
      )

      assert_equal expires_at.to_i, payload["exp"]
    end

    test "extractors return nil when payload is nil" do
      assert_nil Auth::TokenClaims.subject(nil)
      assert_nil Auth::TokenClaims.actor(nil)
      assert_nil Auth::TokenClaims.session_id(nil)
      assert_nil Auth::TokenClaims.jti(nil)
    end
  end
end
