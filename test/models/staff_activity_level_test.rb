# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_activity_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#

require "test_helper"

class StaffActivityLevelTest < ActiveSupport::TestCase
  fixtures :staffs, :staff_statuses, :staff_activity_levels, :staff_activity_events

  test "restrict_with_error on destroy when audits exist" do
    level = StaffActivityLevel.find(StaffActivityLevel::NEYO)
    StaffActivity.create!(
      staff: Staff.find_by!(public_id: "bcde3456"),
      staff_activity_event: StaffActivityEvent.find(StaffActivityEvent::LOGIN_SUCCESS),
      staff_activity_level: level,
      timestamp: Time.current,
    )

    assert_no_difference "StaffActivityLevel.count" do
      assert_not level.destroy
    end
    assert_not_empty level.errors[:base]
    assert_equal "staff activitiesが存在しているので削除できません", level.errors[:base].first
  end

  test "can destroy when no audits exist" do
    level = StaffActivityLevel.create!(id: 2)

    assert_difference "StaffActivityLevel.count", -1 do
      assert level.destroy
    end
  end

  test "accepts integer ids" do
    record = StaffActivityLevel.new(id: 3)
    assert_predicate record, :valid?
  end

  test "NEYO constant is defined" do
    assert_equal 1, StaffActivityLevel::NEYO
  end

  test "has_many association with staff_activities" do
    association = StaffActivityLevel.reflect_on_association(:staff_activities)
    assert_equal :has_many, association.macro
    assert_equal :restrict_with_error, association.options[:dependent]
    assert_equal :level_id, association.options[:foreign_key]
  end
end
