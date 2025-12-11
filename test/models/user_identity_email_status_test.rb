# frozen_string_literal: true

require "test_helper"

class UserIdentityEmailStatusTest < ActiveSupport::TestCase
  test "valid status with id" do
    status = user_identity_email_statuses(:unverified)

    assert_predicate status, :valid?
  end

  test "has many user_identity_emails" do
    status = user_identity_email_statuses(:verified)

    assert UserIdentityEmailStatus.reflect_on_association(:user_identity_emails)
  end

  test "validates presence of id" do
    status = UserIdentityEmailStatus.new(id: nil)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates length of id" do
    status = UserIdentityEmailStatus.new(id: "a" * 256)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates uniqueness of id" do
    existing = user_identity_email_statuses(:unverified)
    duplicate = UserIdentityEmailStatus.new(id: existing.id)

    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end

  test "status constants are defined" do
    assert_equal "UNVERIFIED", UserIdentityEmailStatus::UNVERIFIED
    assert_equal "VERIFIED", UserIdentityEmailStatus::VERIFIED
  end

  test "additional status constants are defined" do
    assert_equal "SUSPENDED", UserIdentityEmailStatus::SUSPENDED
    assert_equal "DELETED", UserIdentityEmailStatus::DELETED
  end

  test "restrict_with_error prevents deletion when emails exist" do
    status = user_identity_email_statuses(:verified)
    # Create a user identity email with this status
    user = users(:one)
    UserIdentityEmail.create!(
      id: SecureRandom.uuid,
      address: "test@example.com",
      user_id: user.id,
      user_identity_email_status_id: status.id
    )

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      status.destroy!
    end
  end
end
