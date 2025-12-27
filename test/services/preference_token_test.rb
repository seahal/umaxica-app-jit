# frozen_string_literal: true

require "test_helper"

class PreferenceTokenTest < ActiveSupport::TestCase
  setup do
    @prefs = { "ct" => "dr" }.freeze
    @host = "example.com".freeze
  end

  test "encodes and decodes token" do
    token = PreferenceToken.encode(@prefs, host: @host)
    assert_not_nil token

    decoded = PreferenceToken.decode(token, host: @host)
    assert_not_nil decoded
    assert_equal "dr", decoded["ct"]
  end

  test "returns nil for invalid token" do
    assert_nil PreferenceToken.decode("invalid", host: @host)
  end

  test "returns nil for wrong host" do
    token = PreferenceToken.encode(@prefs, host: @host)
    assert_nil PreferenceToken.decode(token, host: "wrong.com")
  end
end
