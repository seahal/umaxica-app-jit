# frozen_string_literal: true

require "test_helper"

module Jwt
  class JtiTest < ActiveSupport::TestCase
    test "generate returns a base64url string at the expected length" do
      jti = Jwt::Jti.generate
      assert_match(Jwt::Jti::BASE64URL_REGEX, jti)
      assert_equal Jwt::Jti.encoded_length(Jwt::Jti::DEFAULT_BYTES), jti.length
      assert_no_match(/\A[0-9a-f-]{36}\z/i, jti)
    end

    test "generate accepts a custom byte count" do
      jti = Jwt::Jti.generate(Jwt::Jti::MINIMUM_BYTES)
      assert_equal Jwt::Jti.encoded_length(Jwt::Jti::MINIMUM_BYTES), jti.length
    end

    test "generate returns a different value each call" do
      first = Jwt::Jti.generate
      second = Jwt::Jti.generate
      assert_not_equal first, second
    end
  end
end
