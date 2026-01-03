# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_telephone_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

require "test_helper"

class UserIdentityTelephoneStatusTest < ActiveSupport::TestCase
  test "valid status with id" do
    status = UserIdentityTelephoneStatus.find("UNVERIFIED")

    assert_predicate status, :valid?
  end

  test "has many user_identity_telephones" do
    assert UserIdentityTelephoneStatus.reflect_on_association(:user_identity_telephones)
  end

  test "validates presence of id" do
    status = UserIdentityTelephoneStatus.new(id: nil)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates length of id" do
    status = UserIdentityTelephoneStatus.new(id: "a" * 256)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates uniqueness of id" do
    existing = UserIdentityTelephoneStatus.find("UNVERIFIED")
    duplicate = UserIdentityTelephoneStatus.new(id: existing.id)

    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end

  test "status constants are defined" do
    assert_equal "UNVERIFIED", UserIdentityTelephoneStatus::UNVERIFIED
    assert_equal "VERIFIED", UserIdentityTelephoneStatus::VERIFIED
  end

  test "additional status constants are defined" do
    assert_equal "SUSPENDED", UserIdentityTelephoneStatus::SUSPENDED
    assert_equal "DELETED", UserIdentityTelephoneStatus::DELETED
  end

  test "restrict_with_error prevents deletion when telephones exist" do
    status = UserIdentityTelephoneStatus.find("VERIFIED")
    # Create a user identity telephone with this status
    user = User.find_by!(public_id: "one_id")
    UserIdentityTelephone.create!(
      id: SecureRandom.uuid,
      number: "+81901234567",
      user_id: user.id,
      user_identity_telephone_status_id: status.id,
    )

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      status.destroy!
    end
  end
end
