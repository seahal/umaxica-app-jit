# frozen_string_literal: true

# == Schema Information
#
# Table name: user_telephone_statuses
# Database name: principal
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_user_telephone_statuses_on_id  (id) UNIQUE
#

require "test_helper"

class UserTelephoneStatusTest < ActiveSupport::TestCase
  test "valid status with id" do
    status = UserTelephoneStatus.find(UserTelephoneStatus::UNVERIFIED)

    assert_predicate status, :valid?
  end

  test "has many user_telephones" do
    assert UserTelephoneStatus.reflect_on_association(:user_telephones)
  end

  test "validates presence of id" do
    status = UserTelephoneStatus.new(id: nil)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates uniqueness of id" do
    existing = UserTelephoneStatus.find(UserTelephoneStatus::UNVERIFIED)
    duplicate = UserTelephoneStatus.new(id: existing.id)

    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end

  test "status constants are defined" do
    assert_equal 0, UserTelephoneStatus::NEYO
    assert_equal 1, UserTelephoneStatus::UNVERIFIED
    assert_equal 2, UserTelephoneStatus::VERIFIED
    assert_equal 3, UserTelephoneStatus::SUSPENDED
    assert_equal 4, UserTelephoneStatus::DELETED
  end

  test "validates id is non-negative" do
    record = UserTelephoneStatus.new(id: -1)
    assert_predicate record, :invalid?
    assert_includes record.errors[:id], "must be greater than or equal to 0"
  end

  test "validates id is an integer" do
    record = UserTelephoneStatus.new(id: 1.5)
    assert_predicate record, :invalid?
  end

  test "restrict_with_error prevents deletion when telephones exist" do
    status = UserTelephoneStatus.find(UserTelephoneStatus::VERIFIED)
    # Create a user identity telephone with this status
    user = User.find_by!(public_id: "one_id")
    UserTelephone.create!(
      id: SecureRandom.uuid,
      number: "+81901234567",
      user_id: user.id,
      user_telephone_status_id: status.id,
    )

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      status.destroy!
    end
  end
end
