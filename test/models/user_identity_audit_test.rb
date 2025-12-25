# == Schema Information
#
# Table name: user_identity_audits
#
#  id             :uuid             not null, primary key
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :string           default(""), not null
#  created_at     :datetime         not null
#  event_id       :string(255)      default(""), not null
#  ip_address     :string           default(""), not null
#  level_id       :string           default("NONE"), not null
#  subject_id     :string
#  subject_type   :string           default(""), not null
#  previous_value :text
#  timestamp      :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :uuid             not null
#
# Indexes
#
#  index_user_identity_audits_on_event_id    (event_id)
#  index_user_identity_audits_on_level_id    (level_id)
#  index_user_identity_audits_on_subject_id  (subject_id)
#  index_user_identity_audits_on_user_id     (user_id)
#

require "test_helper"

class UserIdentityAuditTest < ActiveSupport::TestCase
  fixtures :user_identity_audit_events, :users, :staffs

  def setup
    puts "DEBUG: UserIdentityAuditEvent count: #{UserIdentityAuditEvent.count}"
    puts "DEBUG: UserIdentityAuditEvent IDs: #{UserIdentityAuditEvent.pluck(:id)}"
    @user = users(:one)
    @audit_event = user_identity_audit_events(:login_success)
    @level = UserIdentityAuditLevel.find_or_create_by!(id: "INFO")
    @audit = UserIdentityAudit.create!(
      user: @user,
      user_identity_audit_level: @level,
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
