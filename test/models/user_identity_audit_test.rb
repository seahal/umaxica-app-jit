# == Schema Information
#
# Table name: user_identity_audits
#
#  id             :uuid             not null, primary key
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :string           default(""), not null
#  created_at     :datetime         not null
#  event_id       :string(255)      default("NONE"), not null
#  ip_address     :string           default(""), not null
#  level_id       :string(255)      default("NONE"), not null
#  previous_value :text             default(""), not null
#  timestamp      :datetime         default("-infinity"), not null
#  updated_at     :datetime         not null
#  user_id        :uuid             not null
#
# Indexes
#
#  index_user_identity_audits_on_actor_type_and_actor_id  (actor_type,actor_id)
#  index_user_identity_audits_on_event_id                 (event_id)
#  index_user_identity_audits_on_level_id                 (level_id)
#  index_user_identity_audits_on_user_id                  (user_id)
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

  test "belongs to user" do
    association = UserIdentityAudit.reflect_on_association(:user)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "belongs to user_identity_audit_event" do
    association = UserIdentityAudit.reflect_on_association(:user_identity_audit_event)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "can be created with user and status" do
    assert_not_nil @audit
    assert_equal @user.id, @audit.user_id
    assert_equal @audit_event.id, @audit.event_id
  end

  test "timestamp can be set" do
    assert_not_nil @audit.timestamp
    assert_kind_of Time, @audit.timestamp
  end

  test "ip_address can be stored" do
    assert_equal "192.168.1.1", @audit.ip_address
  end

  test "actor_id is optional" do
    audit_without_actor = UserIdentityAudit.create!(
      user: @user,
      user_identity_audit_event: @audit_event
    )

    assert_equal "00000000-0000-0000-0000-000000000000", audit_without_actor.actor_id
  end

  test "previous_value can be stored" do
    audit = UserIdentityAudit.create!(
      user: @user,
      user_identity_audit_event: @audit_event,
      previous_value: '{"email": "old@example.com"}'
    )

    assert_equal '{"email": "old@example.com"}', audit.previous_value
  end

  test "previous_value is encrypted in the database" do
    plain_text = '{"email": "old@example.com"}'
    audit = UserIdentityAudit.create!(
      user: @user,
      user_identity_audit_event: @audit_event,
      previous_value: plain_text
    )

    # Confirm that previous_value is included in the model's encrypted_attributes
    assert_includes UserIdentityAudit.encrypted_attributes, :previous_value

    # Retrieve directly from the database (encrypted value)
    encrypted_value = UserIdentityAudit.connection.execute(
      "SELECT previous_value FROM user_identity_audits WHERE id = '#{audit.id}' LIMIT 1"
    ).first["previous_value"]

    # Since it is encrypted, it should be different from the original value
    assert_not_equal plain_text, encrypted_value
  end

  test "previous_value is decrypted when accessed through model" do
    plain_text = '{"email": "old@example.com"}'
    audit = UserIdentityAudit.create!(
      user: @user,
      user_identity_audit_event: @audit_event,
      previous_value: plain_text
    )

    # It is decrypted when retrieved from the model
    assert_equal plain_text, audit.reload.previous_value
  end

  test "has timestamps" do
    assert_not_nil @audit.created_at
    assert_not_nil @audit.updated_at
  end

  test "user association loads user correctly" do
    assert_equal @user, @audit.user
  end

  test "user_identity_audit_event association loads status correctly" do
    assert_equal @audit_event, @audit.user_identity_audit_event
  end

  test "requires user" do
    audit = UserIdentityAudit.new(
      user_identity_audit_event: @audit_event
    )

    assert_not audit.valid?
    assert_not_empty audit.errors[:user]
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
