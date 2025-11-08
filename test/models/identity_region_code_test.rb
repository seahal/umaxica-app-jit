# == Schema Information
#
# Table name: identifier_region_codes
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class IdentityRegionCodeTest < ActiveSupport::TestCase
  test "the truth" do
    skip "TODO: replace with meaningful identifier region code test or remove"
  end

  test "should inherit from UniversalRecord" do
    assert_operator IdentityRegionCode, :<, UniversalRecord
  end

  test "should create identifier region code with string id" do
    unique_id = "TEST_#{SecureRandom.hex(4)}"
    code = IdentityRegionCode.create(id: unique_id)

    assert_predicate code, :persisted?
    assert_equal unique_id, code.id
  end

  test "should find identifier region code by id" do
    unique_id = "FIND_#{SecureRandom.hex(4)}"
    IdentityRegionCode.create(id: unique_id)
    found = IdentityRegionCode.find(unique_id)

    assert_equal unique_id, found.id
  end

  test "should have timestamps" do
    unique_id = "TIME_#{SecureRandom.hex(4)}"
    code = IdentityRegionCode.create(id: unique_id)

    assert_not_nil code.created_at
    assert_not_nil code.updated_at
  end
end
