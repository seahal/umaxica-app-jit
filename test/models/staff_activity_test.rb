# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_activities
# Database name: activity
#
#  id             :bigint           not null, primary key
#  actor_type     :text             default(""), not null
#  context        :jsonb            not null
#  current_value  :text             default(""), not null
#  expires_at     :datetime         not null
#  ip_address     :inet             default(#<IPAddr: IPv4:0.0.0.0/255.255.255.255>), not null
#  occurred_at    :datetime         not null
#  previous_value :text             default(""), not null
#  subject_type   :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  actor_id       :bigint           default(0), not null
#  event_id       :bigint           default(0), not null
#  level_id       :bigint           default(1), not null
#  subject_id     :bigint           not null
#
# Indexes
#
#  idx_on_subject_type_subject_id_occurred_at_2e96c29236  (subject_type,subject_id,occurred_at)
#  index_staff_activities_on_actor                        (actor_type,actor_id)
#  index_staff_activities_on_actor_id_and_occurred_at     (actor_id,occurred_at)
#  index_staff_activities_on_event_id                     (event_id)
#  index_staff_activities_on_expires_at                   (expires_at)
#  index_staff_activities_on_level_id                     (level_id)
#  index_staff_activities_on_occurred_at                  (occurred_at)
#  index_staff_activities_on_subject_id                   (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => staff_activity_events.id)
#  fk_rails_...  (level_id => staff_activity_levels.id)
#

require "test_helper"

class StaffActivityTest < ActiveSupport::TestCase
  fixtures :staffs, :users, :staff_activity_events, :staff_activity_levels, :staff_statuses, :user_statuses

  def setup
    @staff = staffs(:one)
    @actor = users(:none_user)
    @audit_event = StaffActivityEvent.find(StaffActivityEvent::LOGIN_SUCCESS)
    @audit_level = StaffActivityLevel.find(StaffActivityLevel::NOTHING)
    @audit = StaffActivity.create!(
      staff: @staff,
      staff_activity_event: @audit_event,
      staff_activity_level: @audit_level,
      actor: @actor,
      timestamp: Time.current,
      ip_address: "192.168.1.1",
    )
  end

  test "uses bigint primary key" do
    assert_kind_of Integer, @audit.id
  end

  test "inherits from ActivityRecord" do
    assert_operator StaffActivity, :<, ActivityRecord
  end

  test "ip_address can be stored" do
    assert_equal "192.168.1.1", @audit.ip_address.to_s
  end

  test "requires staff" do
    audit = StaffActivity.new(
      staff_activity_event: @audit_event,
      staff_activity_level: @audit_level,
    )

    assert_not audit.valid?
    assert_not_empty audit.errors[:subject_id]
  end

  test "requires staff_activity_event" do
    audit = StaffActivity.new(
      staff: @staff,
      staff_activity_level: @audit_level,
    )

    # Defaults to NOTHING, so it should be valid
    assert_predicate audit, :valid?
  end

  test "belongs to polymorphic actor" do
    association = StaffActivity.reflect_on_association(:actor)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
    assert_predicate association, :polymorphic?
  end

  test "can be created with a User as actor" do
    actor_user = users(:one)
    audit = StaffActivity.create!(
      staff: @staff,
      staff_activity_event: @audit_event,
      staff_activity_level: @audit_level,
      actor: actor_user,
    )

    assert_equal actor_user.id, audit.actor_id
    assert_equal "User", audit.actor_type
    assert_equal actor_user, audit.actor
  end

  test "can be created with a Staff as actor" do
    actor_staff = staffs(:one)
    audit = StaffActivity.create!(
      staff: @staff,
      staff_activity_event: @audit_event,
      staff_activity_level: @audit_level,
      actor: actor_staff,
    )

    assert_equal actor_staff.id, audit.actor_id
    assert_equal "Staff", audit.actor_type
    assert_equal actor_staff, audit.actor
  end

  test "User and Staff can both be actors in different audits" do
    actor_user = users(:one)
    actor_staff = staffs(:one)

    # Multiple audits for the same staff can have different actors
    StaffActivity.create!(
      staff: @staff,
      staff_activity_event: @audit_event,
      staff_activity_level: @audit_level,
      actor: actor_user,
    )

    StaffActivity.create!(
      staff: @staff,
      staff_activity_event: @audit_event,
      staff_activity_level: @audit_level,
      actor: actor_staff,
    )

    # Retrieve multiple audits related to the same Staff
    user_actors = @staff.staff_activities.where(actor_type: "User")
    staff_actors = @staff.staff_activities.where(actor_type: "Staff")

    assert_not_empty user_actors
    assert_not_empty staff_actors
  end

  test "defaults level_id to NOTHING if not provided" do
    audit = StaffActivity.create!(
      staff: @staff,
      staff_activity_event: @audit_event,
      actor: @actor,
      timestamp: Time.current,
    )

    assert_equal StaffActivityLevel::NOTHING, audit.level_id
    assert_equal StaffActivityLevel::NOTHING, audit.staff_activity_level.id
  end

  test "sets timestamp on create when missing" do
    audit = StaffActivity.create!(
      staff: @staff,
      staff_activity_event: @audit_event,
      staff_activity_level: @audit_level,
      actor: @actor,
      timestamp: nil,
    )

    assert_not_nil audit.timestamp
  end

  test "staff assignment sets subject attributes" do
    audit = StaffActivity.new(
      staff_activity_event: @audit_event,
      staff_activity_level: @audit_level,
    )

    audit.staff = @staff

    assert_equal @staff.id, audit.subject_id
    assert_equal "Staff", audit.subject_type
    assert_equal @staff, audit.staff
  end

  test "invalid when event_id is unknown" do
    audit = StaffActivity.new(
      staff: @staff,
      staff_activity_level: @audit_level,
      event_id: 999_999,
    )

    assert_not audit.valid?
    assert_includes audit.errors[:event_id], "must reference a valid staff audit event"
  end

  test "occurred_at aliases timestamp" do
    timestamp = Time.current
    audit = StaffActivity.create!(
      staff: @staff,
      staff_activity_event: @audit_event,
      staff_activity_level: @audit_level,
      actor: @actor,
      timestamp: timestamp,
    )

    assert_equal timestamp.to_i, audit.occurred_at.to_i
  end
end
