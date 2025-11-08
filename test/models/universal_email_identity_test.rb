# frozen_string_literal: true

# == Schema Information
#
# Table name: universal_email_identifiers
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class UniversalEmailIdentityTest < ActiveSupport::TestCase
  test "should create universal email identifier" do
    identifier = UniversalEmailIdentity.new(
      id: SecureRandom.uuid_v7
    )

    assert_predicate identifier, :valid?
    assert identifier.save
    assert_not_nil identifier.id
  end

  test "should set timestamps on create" do
    identifier = UniversalEmailIdentity.create!(
      id: SecureRandom.uuid_v7
    )

    assert_not_nil identifier.created_at
    assert_not_nil identifier.updated_at
  end

  test "should inherit from UniversalRecord" do
    assert_equal UniversalRecord, UniversalEmailIdentity.superclass
  end

  test "should generate binary id" do
    identifier = UniversalEmailIdentity.create!(
      id: SecureRandom.uuid_v7
    )

    assert_kind_of String, identifier.id
    assert_predicate identifier.id, :present?
  end

  # test "should update timestamps on save" do
  #   identifier = UniversalEmailIdentity.create!(
  #     id: SecureRandom.uuid_v7
  #   )
  #   original_updated_at = identifier.updated_at

  #   sleep(0.1) # Ensure time difference
  #   identifier.touch

  #   assert identifier.updated_at > original_updated_at
  # end

  test "should be valid without additional attributes" do
    identifier = UniversalEmailIdentity.new(
      id: SecureRandom.uuid_v7
    )

    assert_predicate identifier, :valid?
  end

  test "should create multiple identifiers with unique ids" do
    identifier1 = UniversalEmailIdentity.create!(
      id: SecureRandom.uuid_v7
    )
    identifier2 = UniversalEmailIdentity.create!(
      id: SecureRandom.uuid_v7
    )

    assert_not_equal identifier1.id, identifier2.id
  end

  test "should persist data correctly" do
    identifier = UniversalEmailIdentity.create!(
      id: SecureRandom.uuid_v7
    )
    persisted_id = identifier.id

    found_identifier = UniversalEmailIdentity.find(persisted_id)

    assert_equal persisted_id, found_identifier.id
  end

  test "should handle find operations" do
    identifier = UniversalEmailIdentity.create!(
      id: SecureRandom.uuid_v7
    )

    found = UniversalEmailIdentity.find(identifier.id)

    assert_equal identifier.id, found.id
    assert_equal identifier.created_at.to_i, found.created_at.to_i
  end

  test "should support basic queries" do
    identifier1 = UniversalEmailIdentity.create!(
      id: SecureRandom.uuid_v7
    )
    identifier2 = UniversalEmailIdentity.create!(
      id: SecureRandom.uuid_v7
    )

    all_identifiers = UniversalEmailIdentity.all

    assert_includes all_identifiers, identifier1
    assert_includes all_identifiers, identifier2
  end
end
