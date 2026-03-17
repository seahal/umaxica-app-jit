# typed: false
# frozen_string_literal: true

require "test_helper"

class IdentifierBlindIndexTest < ActiveSupport::TestCase
  test "bidx_for_email returns nil for blank email" do
    assert_nil IdentifierBlindIndex.bidx_for_email("")
    assert_nil IdentifierBlindIndex.bidx_for_email("   ")
    assert_nil IdentifierBlindIndex.bidx_for_email(nil)
  end

  test "bidx_for_email returns consistent digest for normalized email" do
    result1 = IdentifierBlindIndex.bidx_for_email("user@example.com")
    result2 = IdentifierBlindIndex.bidx_for_email("  USER@Example.COM  ")

    assert_not_nil result1
    assert_equal result1, result2
  end

  test "bidx_for_telephone returns nil for blank telephone" do
    assert_nil IdentifierBlindIndex.bidx_for_telephone("")
    assert_nil IdentifierBlindIndex.bidx_for_telephone("   ")
    assert_nil IdentifierBlindIndex.bidx_for_telephone(nil)
  end

  test "bidx_for_telephone returns consistent digest for normalized telephone" do
    result1 = IdentifierBlindIndex.bidx_for_telephone("+819012345678")
    result2 = IdentifierBlindIndex.bidx_for_telephone("090-1234-5678")

    assert_not_nil result1
    assert_equal result1, result2
  end
end
