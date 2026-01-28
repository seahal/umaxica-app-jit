# frozen_string_literal: true

# == Schema Information
#
# Table name: user_email_statuses
# Database name: principal
#
#  id :string(255)      default("NEYO"), not null, primary key
#
# Indexes
#
#  index_user_identity_email_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

require "test_helper"

class UserEmailStatusTest < ActiveSupport::TestCase
  test "valid status with id" do
    status = UserEmailStatus.find("UNVERIFIED")

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

  test "validates length of id" do
    status = UserEmailStatus.new(id: "a" * 256)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates uniqueness of id" do
    existing = UserEmailStatus.find("UNVERIFIED")
    duplicate = UserEmailStatus.new(id: existing.id)

    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end

  test "status constants are defined" do
    assert_equal "UNVERIFIED", UserEmailStatus::UNVERIFIED
    assert_equal "VERIFIED", UserEmailStatus::VERIFIED
  end

  test "additional status constants are defined" do
    assert_equal "SUSPENDED", UserEmailStatus::SUSPENDED
    assert_equal "DELETED", UserEmailStatus::DELETED
  end

  test "restrict_with_error prevents deletion when emails exist" do
    status = UserEmailStatus.find("VERIFIED")
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
