# typed: false
# frozen_string_literal: true

require "test_helper"
require "jit/security/jwt/jti_generator"

module Jit
  module Security
    module Jwt
      class JtiGeneratorTest < ActiveSupport::TestCase
        test "generate returns a base64url string at the expected length" do
          jti = Jit::Security::Jwt::JtiGenerator.generate
          assert_match(Jit::Security::Jwt::JtiGenerator::BASE64URL_REGEX, jti)
          assert_equal Jit::Security::Jwt::JtiGenerator.encoded_length(Jit::Security::Jwt::JtiGenerator::DEFAULT_BYTES),
                       jti.length
          assert_no_match(/\A[0-9a-f-]{36}\z/i, jti)
        end

        test "generate accepts a custom byte count" do
          jti = Jit::Security::Jwt::JtiGenerator.generate(Jit::Security::Jwt::JtiGenerator::MINIMUM_BYTES)
          assert_equal Jit::Security::Jwt::JtiGenerator.encoded_length(Jit::Security::Jwt::JtiGenerator::MINIMUM_BYTES),
                       jti.length
        end

        test "generate returns a different value each call" do
          first = Jit::Security::Jwt::JtiGenerator.generate
          second = Jit::Security::Jwt::JtiGenerator.generate
          assert_not_equal first, second
        end
      end
    end
  end
end
