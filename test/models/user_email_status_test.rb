# frozen_string_literal: true

# == Schema Information
#
# Table name: user_email_statuses
# Database name: principal
#
#  id :integer          not null, primary key
#

require "test_helper"

class UserEmailStatusTest < ActiveSupport::TestCase
  test "valid status with id" do
    status = UserEmailStatus.find(UserEmailStatus::UNVERIFIED)

    assert_predicate status, :valid?
  end

  test "has many user_emails" do
    assert UserEmailStatus.reflect_on_association(:user_emails)
  end

  test "validates presence of id" do
    status = UserEmailStatus.new(id: nil)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates uniqueness of id" do
    existing = UserEmailStatus.find(UserEmailStatus::UNVERIFIED)
    duplicate = UserEmailStatus.new(id: existing.id)

    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end

  test "status constants are defined" do
    assert_equal 0, UserEmailStatus::NEYO
    assert_equal 1, UserEmailStatus::UNVERIFIED
    assert_equal 2, UserEmailStatus::VERIFIED
    assert_equal 3, UserEmailStatus::SUSPENDED
    assert_equal 4, UserEmailStatus::DELETED
  end

  test "validates id is non-negative" do
    record = UserEmailStatus.new(id: -1)
    assert_predicate record, :invalid?
    assert_includes record.errors[:id], "must be greater than or equal to 0"
  end

  test "validates id is an integer" do
    record = UserEmailStatus.new(id: 1.5)
    assert_predicate record, :invalid?
  end

  test "restrict_with_error prevents deletion when emails exist" do
    status = UserEmailStatus.find(UserEmailStatus::VERIFIED)
    # Create a user identity email with this status
    user = User.find_by!(public_id: "one_id")
    UserEmail.create!(
      id: SecureRandom.uuid,
      address: "test@example.com",
      user_id: user.id,
      user_email_status_id: status.id,
    )

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      status.destroy!
    end
  end
end
