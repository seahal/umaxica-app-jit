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
  test "has correct constants" do
    assert_equal 0, UserTelephoneStatus::NOTHING
    assert_equal 1, UserTelephoneStatus::VERIFIED
    assert_equal 2, UserTelephoneStatus::UNVERIFIED
    assert_equal 3, UserTelephoneStatus::SUSPENDED
    assert_equal 4, UserTelephoneStatus::DELETED
    assert_equal 5, UserTelephoneStatus::LEGACY_NOTHING
    assert_equal 6, UserTelephoneStatus::UNVERIFIED_WITH_SIGN_UP
    assert_equal 7, UserTelephoneStatus::VERIFIED_WITH_SIGN_UP
  end

  test "can load nothing status from db" do
    status = UserTelephoneStatus.find(UserTelephoneStatus::NOTHING)

    assert_equal 0, status.id
  end

  test "has many user_telephones" do
    assert UserTelephoneStatus.reflect_on_association(:user_telephones)
  end

  test "status ids are integers" do
    assert_kind_of Integer, UserTelephoneStatus::NOTHING
    assert_kind_of Integer, UserTelephoneStatus::VERIFIED
    assert_kind_of Integer, UserTelephoneStatus::UNVERIFIED
    assert_kind_of Integer, UserTelephoneStatus::SUSPENDED
    assert_kind_of Integer, UserTelephoneStatus::DELETED
  end

  test "ensure_defaults! creates missing default records" do
    UserTelephoneStatus.where(id: UserTelephoneStatus::NOTHING).destroy_all

    assert_difference("UserTelephoneStatus.count") do
      UserTelephoneStatus.ensure_defaults!
    end
  end

  test "ensure_defaults! skips when all defaults exist" do
    UserTelephoneStatus.ensure_defaults!

    assert_no_difference("UserTelephoneStatus.count") do
      UserTelephoneStatus.ensure_defaults!
    end
  end

  test "restrict_with_error prevents deletion when telephones exist" do
    status = UserTelephoneStatus.find(UserTelephoneStatus::VERIFIED)
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
