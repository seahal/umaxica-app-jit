# frozen_string_literal: true

require "test_helper"
require "openssl"
require_relative "../../app/controllers/concerns/preference/base"

class PreferenceTokenServiceTest < ActiveSupport::TestCase
  setup do
    @prefs = { "ct" => "dr" }.freeze
    @host = "example.com".freeze
    @preference_type = "AppPreference".freeze
    @public_id = "pref_public_id".freeze
    @jti = "test-jti-#{SecureRandom.uuid}".freeze
    @private_key = OpenSSL::PKey::EC.generate("secp384r1")
    @public_key = @private_key
    @issuer = "jit-preference".freeze
    @audiences = ["example.com"].freeze
  end

  test "encodes and decodes token" do
    with_jwt_keys do
      token = Preference::Token.encode(
        @prefs,
        host: @host,
        preference_type: @preference_type,
        public_id: @public_id,
        jti: @jti,
      )
      assert_not_nil token

      decoded = Preference::Token.decode(token, host: @host)
      assert_not_nil decoded
      assert_equal "dr", decoded.dig("preferences", "ct")
      assert_equal @jti, decoded["jti"]
    end
  end

  test "returns nil for invalid token" do
    with_jwt_keys do
      assert_nil Preference::Token.decode("invalid", host: @host)
    end
  end

  test "returns nil for wrong host" do
    with_jwt_keys do
      token = Preference::Token.encode(
        @prefs,
        host: @host,
        preference_type: @preference_type,
        public_id: @public_id,
        jti: @jti,
      )
      assert_nil Preference::Token.decode(token, host: "wrong.com")
    end
  end

  private

  def with_jwt_keys
    Preference::JwtConfiguration.stub(:private_key, @private_key) do
      Preference::JwtConfiguration.stub(:public_key, @public_key) do
        Preference::JwtConfiguration.stub(:issuer, @issuer) do
          Preference::JwtConfiguration.stub(:audiences, @audiences) do
            yield
          end
        end
      end
    end
  end
end
