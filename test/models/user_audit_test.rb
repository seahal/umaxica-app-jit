# frozen_string_literal: true

# == Schema Information
#
# Table name: user_audits
#
#  id             :uuid             not null, primary key
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :string           default(""), not null
#  created_at     :datetime         not null
#  event_id       :string(255)      default("NEYO"), not null
#  ip_address     :string           default(""), not null
#  level_id       :string           default("NEYO"), not null
#  previous_value :text
#  subject_id     :string
#  subject_type   :string           default(""), not null
#  timestamp      :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :uuid             not null
#  context        :jsonb            default("{}"), not null
#
# Indexes
#
#  index_user_identity_audits_on_event_id    (event_id)
#  index_user_identity_audits_on_level_id    (level_id)
#  index_user_identity_audits_on_subject_id  (subject_id)
#  index_user_identity_audits_on_user_id     (user_id)
#
#

require "test_helper"

class UserAuditTest < ActiveSupport::TestCase
  fixtures :users, :staffs, :user_audit_events, :user_audit_levels, :user_statuses

  def setup
    @user = users(:one)
    @audit_event = UserAuditEvent.find("LOGIN_SUCCESS")
    @level = UserAuditLevel.find_or_create_by!(id: "INFO")
    @audit = UserAudit.create!(
      user: @user,
      user_audit_level: @level,
      user_audit_event: @audit_event,
      timestamp: Time.current,
      ip_address: "192.168.1.1",
    )
  end

  test "inherits from PrincipalRecord" do
    assert_operator UserAudit, :<, PrincipalRecord
  end

  test "ip_address can be stored" do
    assert_equal "192.168.1.1", @audit.ip_address.to_s
  end

  test "requires user" do
    audit = UserAudit.new(
      user_audit_event: @audit_event,
    )

    assert_not audit.valid?
    assert_not_empty audit.errors[:subject_id]
  end

  test "requires user_audit_event" do
    audit = UserAudit.new(
      user: @user,
    )

    # Defaults to NONE, so it should be valid
    assert_predicate audit, :valid?
  end

  test "validates foreign key constraint on event_id" do
    audit = UserAudit.new(
      user: @user,
      event_id: "INVALID_EVENT_ID",
      timestamp: Time.current,
    )

    # Now validation should catch it before reaching the database
    assert_not audit.valid?
    assert_not_empty audit.errors[:event_id]
    assert_includes audit.errors[:event_id], "must reference a valid user audit event"
  end

  test "belongs to polymorphic actor" do
    association = UserAudit.reflect_on_association(:actor)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
    assert_predicate association, :polymorphic?
  end

  test "can be created with a User as actor" do
    actor_user = users(:one)
    audit = UserAudit.create!(
      user: @user,
      user_audit_event: @audit_event,
      actor: actor_user,
    )

    assert_equal actor_user.id, audit.actor_id
    assert_equal "User", audit.actor_type
    assert_equal actor_user, audit.actor
  end

  test "can be created with a Staff as actor" do
    actor_staff = staffs(:one)
    audit = UserAudit.create!(
      user: @user,
      user_audit_event: @audit_event,
      actor: actor_staff,
    )

    assert_equal actor_staff.id, audit.actor_id
    assert_equal "Staff", audit.actor_type
    assert_equal actor_staff, audit.actor
  end

  test "User and Staff can both be actors in different audits" do
    actor_user = users(:one)
    actor_staff = staffs(:one)

    # Multiple audits for the same user can have different actors
    UserAudit.create!(
      user: @user,
      user_audit_event: @audit_event,
      actor: actor_user,
    )

    UserAudit.create!(
      user: @user,
      user_audit_event: @audit_event,
      actor: actor_staff,
    )

    # Retrieve multiple audits related to the same User
    user_actors = @user.user_audits.where(actor_type: "User")
    staff_actors = @user.user_audits.where(actor_type: "Staff")

    assert_not_empty user_actors
    assert_not_empty staff_actors
  end

  # Additional tests for helper methods
  test "user helper method returns user" do
    assert_equal @user, @audit.user
  end

  test "user_id helper method returns user id" do
    assert_equal @user.id.to_s, @audit.user_id
  end

  test "occurred_at alias works" do
    assert_equal @audit.timestamp, @audit.occurred_at
  end

  test "set_timestamp defaults to current time" do
    audit = UserAudit.new(user_audit_event: @audit_event)
    audit.user = @user
    audit.save!
    assert_not_nil audit.timestamp
  end

  test "actor defaults to null user if blank" do
    # When creating without actor
    audit = UserAudit.create!(
      user: @user,
      user_audit_event: @audit_event,
      actor: nil,
    )

    assert_equal "00000000-0000-0000-0000-000000000000", audit.actor_id
    assert_equal "User", audit.actor_type
  end
end
