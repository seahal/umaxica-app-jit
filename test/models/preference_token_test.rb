# frozen_string_literal: true

require "test_helper"

class PreferenceTokenTest < ActiveSupport::TestCase
  setup do
    @host = "example.com".freeze
    @preferences = {
      "lx" => "en",
      "ri" => "us",
      "tz" => "utc",
      "ct" => "dark",
    }.freeze
  end

  test "encode returns a token string" do
    token = PreferenceToken.encode(@preferences, host: @host)
    assert_not_nil token
    assert_kind_of String, token
  end

  test "encode returns nil for blank preferences or host" do
    assert_nil PreferenceToken.encode({}, host: @host)
    assert_nil PreferenceToken.encode(@preferences, host: nil)
  end

  test "decode returns payload for valid token and host" do
    token = PreferenceToken.encode(@preferences, host: @host)
    payload = PreferenceToken.decode(token, host: @host)

    assert_kind_of Hash, payload
    assert_equal @host, payload["host"]
    assert_equal @preferences, payload["preferences"]
  end

  test "decode returns nil for mismatched host" do
    token = PreferenceToken.encode(@preferences, host: @host)
    assert_nil PreferenceToken.decode(token, host: "other.com")
  end

  test "decode returns nil for invalid token" do
    assert_nil PreferenceToken.decode("invalid.token", host: @host)
  end

  test "decode returns nil for blank inputs" do
    assert_nil PreferenceToken.decode(nil, host: @host)
    assert_nil PreferenceToken.decode("token", host: nil)
  end

  test "extract_preferences returns preferences hash from payload" do
    payload = { "preferences" => @preferences }
    assert_equal @preferences, PreferenceToken.extract_preferences(payload)
  end

  test "extract_preferences returns empty hash for invalid payload" do
    assert_empty(PreferenceToken.extract_preferences(nil))
    assert_empty(PreferenceToken.extract_preferences({}))
  end

  test "handle invalid signature gracefully" do
    # Create a token and tamper with it
    token = PreferenceToken.encode(@preferences, host: @host)
    # This is a basic way to tamper; might need more sophistication if it's not just base64
    # But since it's MessageVerifier, changing any char should fail signature
    tampered_token = token.reverse

    assert_nil PreferenceToken.decode(tampered_token, host: @host)
  end
end
