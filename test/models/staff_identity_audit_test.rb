# == Schema Information
#
# Table name: staff_identity_audits
#
#  id             :uuid             not null, primary key
#  subject_id     :string           not null
#  subject_type   :text             not null
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :text             default(""), not null
#  event_id       :string(255)      default("NONE"), not null
#  level_id       :string(255)      default("NONE"), not null
#  occurred_at    :datetime         not null
#  expires_at     :datetime         not null
#  ip_address     :inet             default("0.0.0.0"), not null
#  context        :jsonb            default("{}"), not null
#  previous_value :text             default(""), not null
#  current_value  :text             default(""), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  idx_on_subject_type_subject_id_occurred_at_2e96c29236    (subject_type,subject_id,occurred_at)
#  index_staff_identity_audits_on_actor_id_and_occurred_at  (actor_id,occurred_at)
#  index_staff_identity_audits_on_event_id                  (event_id)
#  index_staff_identity_audits_on_expires_at                (expires_at)
#  index_staff_identity_audits_on_level_id                  (level_id)
#  index_staff_identity_audits_on_occurred_at               (occurred_at)
#

require "test_helper"

class StaffIdentityAuditTest < ActiveSupport::TestCase
  def setup
    @staff = staffs(:one)
    @actor = users(:none_user)
    @audit_event = staff_identity_audit_events(:one)
    @audit_level = staff_identity_audit_levels(:none)
    @audit = StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_event: @audit_event,
      staff_identity_audit_level: @audit_level,
      actor: @actor,
      timestamp: Time.current,
      ip_address: "192.168.1.1"
    )
  end

  test "inherits from IdentitiesRecord" do
    assert_operator StaffIdentityAudit, :<, IdentitiesRecord
  end

  test "ip_address can be stored" do
    assert_equal "192.168.1.1", @audit.ip_address.to_s
  end

  test "requires staff" do
    audit = StaffIdentityAudit.new(
      staff_identity_audit_event: @audit_event,
      staff_identity_audit_level: @audit_level
    )

    assert_not audit.valid?
    assert_not_empty audit.errors[:subject_id]
  end

  test "requires staff_identity_audit_event" do
    audit = StaffIdentityAudit.new(
      staff: @staff,
      staff_identity_audit_level: @audit_level
    )

    # Defaults to NONE, so it should be valid
    assert_predicate audit, :valid?
  end

  test "belongs to polymorphic actor" do
    association = StaffIdentityAudit.reflect_on_association(:actor)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
    assert_predicate association, :polymorphic?
  end

  test "can be created with a User as actor" do
    actor_user = users(:one)
    audit = StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_event: @audit_event,
      staff_identity_audit_level: @audit_level,
      actor: actor_user
    )

    assert_equal actor_user.id, audit.actor_id
    assert_equal "User", audit.actor_type
    assert_equal actor_user, audit.actor
  end

  test "can be created with a Staff as actor" do
    actor_staff = staffs(:one)
    audit = StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_event: @audit_event,
      staff_identity_audit_level: @audit_level,
      actor: actor_staff
    )

    assert_equal actor_staff.id, audit.actor_id
    assert_equal "Staff", audit.actor_type
    assert_equal actor_staff, audit.actor
  end

  test "User and Staff can both be actors in different audits" do
    actor_user = users(:one)
    actor_staff = staffs(:one)

    # Multiple audits for the same staff can have different actors
    StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_event: @audit_event,
      staff_identity_audit_level: @audit_level,
      actor: actor_user
    )

    StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_event: @audit_event,
      staff_identity_audit_level: @audit_level,
      actor: actor_staff
    )

    # Retrieve multiple audits related to the same Staff
    user_actors = @staff.staff_identity_audits.where(actor_type: "User")
    staff_actors = @staff.staff_identity_audits.where(actor_type: "Staff")

    assert_not_empty user_actors
    assert_not_empty staff_actors
  end

  test "defaults level_id to NONE if not provided" do
    audit = StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_event: @audit_event,
      actor: @actor,
      timestamp: Time.current
    )

    assert_equal "NONE", audit.level_id
    assert_equal "NONE", audit.staff_identity_audit_level.id
  end
end
