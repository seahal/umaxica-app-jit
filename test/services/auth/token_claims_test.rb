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
      assert_equal unix_timestamp(issued_at), payload["iat"]
      assert_equal unix_timestamp(issued_at), payload["nbf"]
      assert_equal unix_timestamp(issued_at + 10.minutes), payload["exp"]
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

      assert_equal unix_timestamp(expires_at), payload["exp"]
    end

    test "extractors return nil when payload is nil" do
      assert_nil Auth::TokenClaims.subject(nil)
      assert_nil Auth::TokenClaims.actor(nil)
      assert_nil Auth::TokenClaims.session_id(nil)
      assert_nil Auth::TokenClaims.jti(nil)
    end

    test "build includes prf claim when preference is provided" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      preference = { language: "en", region: "us", timezone: "America/New_York", theme: "dr" }
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "user",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
        preference: preference,
      )

      assert_kind_of Hash, payload["prf"]
      assert_equal "en", payload["prf"]["lx"]
      assert_equal "us", payload["prf"]["ri"]
      assert_equal "America/New_York", payload["prf"]["tz"]
      assert_equal "dr", payload["prf"]["ct"]
    end

    test "build omits prf claim when preference is nil" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "user",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
        preference: nil,
      )

      assert_nil payload["prf"]
    end

    test "build omits prf claim when preference is not provided" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "user",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
      )

      assert_nil payload["prf"]
    end

    test "preference extracts prf claim from payload" do
      payload = { "prf" => { "lx" => "ja", "ri" => "jp", "tz" => "Asia/Tokyo", "ct" => "sy" } }
      prf = Auth::TokenClaims.preference(payload)

      assert_equal "ja", prf["lx"]
      assert_equal "jp", prf["ri"]
      assert_equal "Asia/Tokyo", prf["tz"]
      assert_equal "sy", prf["ct"]
    end

    test "preference returns nil when prf claim is absent" do
      payload = { "sub" => 42, "act" => "user" }

      assert_nil Auth::TokenClaims.preference(payload)
    end

    test "preference returns nil when payload is nil" do
      assert_nil Auth::TokenClaims.preference(nil)
    end

    test "roundtrip: build prf claim can be extracted and used with Current::Preference.from_jwt" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      preference = { language: "en", region: "us", timezone: "America/New_York", theme: "dr" }
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "user",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
        preference: preference,
      )

      prf_claim = Auth::TokenClaims.preference(payload)
      pref = Current::Preference.from_jwt(prf_claim)

      assert_not pref.null?
      assert_equal "en", pref.language
      assert_equal "us", pref.region
      assert_equal "America/New_York", pref.timezone
      assert_equal "dr", pref.theme
      assert_predicate pref, :dark_mode?
    end

    private

    def unix_timestamp(value)
      value.to_i
    end
  end
end
