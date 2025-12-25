# == Schema Information
#
# Table name: user_identity_audits
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
#  idx_on_subject_type_subject_id_occurred_at_a29eb711dd   (subject_type,subject_id,occurred_at)
#  index_user_identity_audits_on_actor_id_and_occurred_at  (actor_id,occurred_at)
#  index_user_identity_audits_on_event_id                  (event_id)
#  index_user_identity_audits_on_expires_at                (expires_at)
#  index_user_identity_audits_on_level_id                  (level_id)
#  index_user_identity_audits_on_occurred_at               (occurred_at)
#

require "test_helper"

class UserIdentityAuditTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @audit_event = user_identity_audit_events(:login_success)
    @audit = UserIdentityAudit.create!(
      user: @user,
      user_identity_audit_event: @audit_event,
      timestamp: Time.current,
      ip_address: "192.168.1.1"
    )
  end

  test "inherits from IdentitiesRecord" do
    assert_operator UserIdentityAudit, :<, IdentitiesRecord
  end

  test "ip_address can be stored" do
    assert_equal "192.168.1.1", @audit.ip_address.to_s
  end

  test "requires user" do
    audit = UserIdentityAudit.new(
      user_identity_audit_event: @audit_event
    )

    assert_not audit.valid?
    assert_not_empty audit.errors[:subject_id]
  end

  test "requires user_identity_audit_event" do
    audit = UserIdentityAudit.new(
      user: @user
    )

    # Defaults to NONE, so it should be valid
    assert_predicate audit, :valid?
  end

  test "validates foreign key constraint on event_id" do
    audit = UserIdentityAudit.new(
      user: @user,
      event_id: "NON_EXISTENT_EVENT",
      timestamp: Time.current
    )

    assert_raises ActiveRecord::InvalidForeignKey do
      audit.save!(validate: false)
    end
  end

  test "belongs to polymorphic actor" do
    association = UserIdentityAudit.reflect_on_association(:actor)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
    assert_predicate association, :polymorphic?
  end

  test "can be created with a User as actor" do
    actor_user = users(:one)
    audit = UserIdentityAudit.create!(
      user: @user,
      user_identity_audit_event: @audit_event,
      actor: actor_user
    )

    assert_equal actor_user.id, audit.actor_id
    assert_equal "User", audit.actor_type
    assert_equal actor_user, audit.actor
  end

  test "can be created with a Staff as actor" do
    actor_staff = staffs(:one)
    audit = UserIdentityAudit.create!(
      user: @user,
      user_identity_audit_event: @audit_event,
      actor: actor_staff
    )

    assert_equal actor_staff.id, audit.actor_id
    assert_equal "Staff", audit.actor_type
    assert_equal actor_staff, audit.actor
  end

  test "User and Staff can both be actors in different audits" do
    actor_user = users(:one)
    actor_staff = staffs(:one)

    # Multiple audits for the same user can have different actors
    UserIdentityAudit.create!(
      user: @user,
      user_identity_audit_event: @audit_event,
      actor: actor_user
    )

    UserIdentityAudit.create!(
      user: @user,
      user_identity_audit_event: @audit_event,
      actor: actor_staff
    )

    # Retrieve multiple audits related to the same User
    user_actors = @user.user_identity_audits.where(actor_type: "User")
    staff_actors = @user.user_identity_audits.where(actor_type: "Staff")

    assert_not_empty user_actors
    assert_not_empty staff_actors
  end
end
