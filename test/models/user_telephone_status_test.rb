# frozen_string_literal: true

# == Schema Information
#
# Table name: user_telephone_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

require "test_helper"

class UserTelephoneStatusTest < ActiveSupport::TestCase
  test "valid status with id" do
    status = UserTelephoneStatus.find("UNVERIFIED")

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

  test "validates length of id" do
    status = UserTelephoneStatus.new(id: "a" * 256)

    assert_predicate status, :invalid?
    assert_predicate status.errors[:id], :any?
  end

  test "validates uniqueness of id" do
    existing = UserTelephoneStatus.find("UNVERIFIED")
    duplicate = UserTelephoneStatus.new(id: existing.id)

    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end

  test "status constants are defined" do
    assert_equal "UNVERIFIED", UserTelephoneStatus::UNVERIFIED
    assert_equal "VERIFIED", UserTelephoneStatus::VERIFIED
  end

  test "additional status constants are defined" do
    assert_equal "SUSPENDED", UserTelephoneStatus::SUSPENDED
    assert_equal "DELETED", UserTelephoneStatus::DELETED
  end

  test "restrict_with_error prevents deletion when telephones exist" do
    status = UserTelephoneStatus.find("VERIFIED")
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
