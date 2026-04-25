# typed: false
# frozen_string_literal: true

require "test_helper"

class Oidc::JwksServiceTest < ActiveSupport::TestCase
  test "jwk_set returns a hash with keys array" do
    result = Oidc::JwksService.jwk_set

    assert_kind_of Hash, result
    assert result.key?(:keys)
    assert_kind_of Array, result[:keys]
  end

  test "jwk_set keys have required JWK fields when key is configured" do
    result = Oidc::JwksService.jwk_set

    # If no key is configured, keys array may be empty
    return if result[:keys].empty?

    key = result[:keys].first

    assert_predicate key[:kty], :present?, "JWK should have kty"
    assert_predicate key[:kid], :present?, "JWK should have kid"
    assert_equal "sig", key[:use], "JWK use should be sig"
    assert_equal "ES384", key[:alg], "JWK alg should be ES384"
  end

  test "jwk_set returns empty keys when no public key configured" do
    Jit::Security::Jwt::Keyring.stub(:public_key_for, nil) do
      result = Oidc::JwksService.jwk_set

      assert_equal({ keys: [] }, result)
    end
  end
end
