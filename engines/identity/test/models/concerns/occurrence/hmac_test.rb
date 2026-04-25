# typed: false
# frozen_string_literal: true

require "test_helper"

module Occurrence
  class HmacTest < ActiveSupport::TestCase
    test "digest returns a non-blank string for email" do
      result = Hmac.digest(kind: "email", body: "test@example.com")

      assert_not_nil result
      assert_not result.blank?
      assert_kind_of String, result
    end

    test "digest returns a non-blank string for telephone" do
      result = Hmac.digest(kind: "telephone", body: "+819012345678")

      assert_not_nil result
      assert_not result.blank?
      assert_kind_of String, result
    end

    test "digest returns consistent value for same input" do
      result1 = Hmac.digest(kind: "email", body: "test@example.com")
      result2 = Hmac.digest(kind: "email", body: "test@example.com")

      assert_equal result1, result2
    end

    test "digest returns different values for different inputs" do
      result1 = Hmac.digest(kind: "email", body: "user1@example.com")
      result2 = Hmac.digest(kind: "email", body: "user2@example.com")

      assert_not_equal result1, result2
    end

    test "digest returns different values for different kinds" do
      result1 = Hmac.digest(kind: "email", body: "test")
      result2 = Hmac.digest(kind: "telephone", body: "test")

      assert_not_equal result1, result2
    end
  end
end
