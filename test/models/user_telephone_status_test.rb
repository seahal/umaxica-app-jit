# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_telephone_statuses
# Database name: principal
#
#  id :bigint           not null, primary key
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

  test "status constants are defined" do
    assert_equal 1, UserTelephoneStatus::UNVERIFIED
    assert_equal 2, UserTelephoneStatus::VERIFIED
    assert_equal 3, UserTelephoneStatus::SUSPENDED
    assert_equal 4, UserTelephoneStatus::DELETED
    assert_equal 5, UserTelephoneStatus::NOTHING
  end
  test "status ids are integers" do
    assert_kind_of Integer, UserTelephoneStatus::UNVERIFIED
    assert_kind_of Integer, UserTelephoneStatus::VERIFIED
    assert_kind_of Integer, UserTelephoneStatus::SUSPENDED
    assert_kind_of Integer, UserTelephoneStatus::DELETED
    assert_kind_of Integer, UserTelephoneStatus::NOTHING
  end

  test "restrict_with_error prevents deletion when telephones exist" do
    status = UserTelephoneStatus.find(UserTelephoneStatus::VERIFIED)
    # Create a user identity telephone with this status
    user = User.find_by!(public_id: "one_id")
    UserTelephone.create!(
      number: "+81901234567",
      user_id: user.id,
      user_telephone_status_id: status.id,
    )

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      status.destroy!
    end
  end
end
