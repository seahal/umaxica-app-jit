# typed: false
# frozen_string_literal: true

require "test_helper"

module Auth
  class TokenClaimsTest < ActiveSupport::TestCase
    DummyResource = Struct.new(:id)

    def setup_token_claims_payload
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "user",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
      )
      [payload, issued_at]
    end

    test "build includes subject and actor claims" do
      payload, _issued_at = setup_token_claims_payload

      assert_equal 42, payload["sub"]
      assert_equal "user", payload["act"]
    end

    test "build includes session id claim" do
      payload, _issued_at = setup_token_claims_payload

      assert_equal "sess_abc", payload["sid"]
    end

    test "build includes timestamp claims" do
      payload, issued_at = setup_token_claims_payload

      assert_equal unix_timestamp(issued_at), payload["iat"]
      assert_equal unix_timestamp(issued_at + 10.minutes), payload["exp"]
    end

    test "build excludes nbf claim" do
      payload, _issued_at = setup_token_claims_payload

      assert_nil payload["nbf"], "nbf should not be included"
    end

    test "build excludes prf claim when preferences not provided" do
      payload, _issued_at = setup_token_claims_payload

      assert_nil payload["prf"], "prf should not be included when no preferences given"
    end

    test "build includes type and issuer claims" do
      payload, _issued_at = setup_token_claims_payload

      assert_equal "auth-access-token;user", payload["typ"]
      assert_equal Authentication::Base::JwtConfiguration.issuer("user"), payload["iss"]
    end

    test "build includes audience and jti claims" do
      payload, _issued_at = setup_token_claims_payload

      assert_equal Authentication::Base::JwtConfiguration.audiences("user"), payload["aud"]
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

    test "build does not include prf claim when preferences is nil" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "user",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
      )

      assert_nil payload["prf"], "auth JWT should not contain preference data when nil"
    end

    test "build includes prf claim when preferences hash provided" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      prefs = { "lx" => "en", "ri" => "us", "tz" => "America/New_York", "ct" => "dr" }
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "user",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
        preferences: prefs,
      )

      assert_equal prefs, payload["prf"]
    end

    test "build excludes prf claim when preferences is empty hash" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "user",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
        preferences: {},
      )

      assert_nil payload["prf"], "prf should not be included for empty preferences"
    end

    test "build excludes prf claim when preferences is not a hash" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "user",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
        preferences: "invalid",
      )

      assert_nil payload["prf"], "prf should not be included for non-hash preferences"
    end

    test "preferences extractor reads prf claim" do
      payload = { "prf" => { "lx" => "ja", "ri" => "jp" } }

      assert_equal({ "lx" => "ja", "ri" => "jp" }, Auth::TokenClaims.preferences(payload))
    end

    test "preferences extractor returns nil when prf absent" do
      assert_nil Auth::TokenClaims.preferences({})
      assert_nil Auth::TokenClaims.preferences(nil)
    end

    test "prf claim roundtrips through Current::Preference.from_jwt" do
      prefs = { "lx" => "en", "ri" => "us", "tz" => "America/New_York", "ct" => "dr" }
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "user",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
        preferences: prefs,
      )

      pref = Current::Preference.from_jwt(payload["prf"])

      assert_equal "en", pref.language
      assert_equal "us", pref.region
      assert_equal "America/New_York", pref.timezone
      assert_equal "dr", pref.theme
      assert_predicate pref, :dark_mode?
      assert_not_predicate pref, :null?
    end

    test "build includes subject_type, acr, amr claims by default" do
      payload, _issued_at = setup_token_claims_payload

      assert_equal "user", payload["subject_type"]
      assert_equal "aal1", payload["acr"]
      assert_equal [], payload["amr"]
    end

    test "build includes custom acr claim" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "user",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
        acr: "aal2",
      )

      assert_equal "aal2", payload["acr"]
    end

    test "build includes custom amr claim" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "user",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
        amr: ["email_otp"],
      )

      assert_equal ["email_otp"], payload["amr"]
    end

    test "build includes multiple amr values for step-up" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "user",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
        amr: ["email_otp", "totp"],
      )

      assert_equal ["email_otp", "totp"], payload["amr"]
    end

    test "build rejects invalid amr values" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")

      assert_raises(ArgumentError) do
        Auth::TokenClaims.build(
          resource: DummyResource.new(42),
          session_public_id: "sess_abc",
          resource_type: "user",
          issued_at: issued_at,
          access_token_ttl: 10.minutes,
          amr: ["social"],
        )
      end
    end

    test "build uses resource_type as default subject_type" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      payload = Auth::TokenClaims.build(
        resource: DummyResource.new(42),
        session_public_id: "sess_abc",
        resource_type: "staff",
        issued_at: issued_at,
        access_token_ttl: 10.minutes,
      )

      assert_equal "staff", payload["subject_type"]
    end

    test "build rejects invalid subject_type" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      assert_raises(ArgumentError) do
        Auth::TokenClaims.build(
          resource: DummyResource.new(42),
          session_public_id: "sess_abc",
          resource_type: "user",
          issued_at: issued_at,
          access_token_ttl: 10.minutes,
          subject_type: "admin",
        )
      end
    end

    test "build rejects invalid acr" do
      issued_at = Time.zone.parse("2026-02-22 12:00:00")
      assert_raises(ArgumentError) do
        Auth::TokenClaims.build(
          resource: DummyResource.new(42),
          session_public_id: "sess_abc",
          resource_type: "user",
          issued_at: issued_at,
          access_token_ttl: 10.minutes,
          acr: "aal3",
        )
      end
    end

    test "acr extractor reads acr claim" do
      payload = { "acr" => "aal2" }

      assert_equal "aal2", Auth::TokenClaims.acr(payload)
    end

    test "acr extractor returns nil when absent" do
      assert_nil Auth::TokenClaims.acr({})
      assert_nil Auth::TokenClaims.acr(nil)
    end

    test "amr extractor reads amr claim" do
      payload = { "amr" => ["email_otp", "totp"] }

      assert_equal ["email_otp", "totp"], Auth::TokenClaims.amr(payload)
    end

    test "amr extractor returns empty array when absent" do
      assert_equal [], Auth::TokenClaims.amr({})
      assert_equal [], Auth::TokenClaims.amr(nil)
    end

    test "subject_type extractor reads subject_type claim" do
      payload = { "subject_type" => "staff" }

      assert_equal "staff", Auth::TokenClaims.subject_type(payload)
    end

    test "subject_type extractor returns nil when absent" do
      assert_nil Auth::TokenClaims.subject_type({})
      assert_nil Auth::TokenClaims.subject_type(nil)
    end

    private

    def unix_timestamp(value)
      value.to_i
    end
  end
end
