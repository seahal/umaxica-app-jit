require "test_helper"

class StaffIdentityAuditTest < ActiveSupport::TestCase
  def setup
    @staff = staffs(:one)
    @audit_event = staff_identity_audit_events(:one)
    @audit = StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_event: @audit_event,
      timestamp: Time.current,
      ip_address: "192.168.1.1"
    )
  end

  test "inherits from IdentitiesRecord" do
    assert_operator StaffIdentityAudit, :<, IdentitiesRecord
  end

  test "belongs to staff" do
    association = StaffIdentityAudit.reflect_on_association(:staff)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "belongs to staff_identity_audit_event" do
    association = StaffIdentityAudit.reflect_on_association(:staff_identity_audit_event)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "can be created with staff and status" do
    assert_not_nil @audit
    assert_equal @staff.id, @audit.staff_id
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
    audit_without_actor = StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_event: @audit_event
    )

    assert_nil audit_without_actor.actor_id
  end

  test "previous_value can be stored" do
    audit = StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_event: @audit_event,
      previous_value: '{"name": "old"}'
    )

    assert_equal '{"name": "old"}', audit.previous_value
  end

  test "previous_value is encrypted in the database" do
    plain_text = '{"name": "old"}'
    audit = StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_event: @audit_event,
      previous_value: plain_text
    )

    # モデルの encrypted_attributes に previous_value が含まれていることを確認
    assert_includes StaffIdentityAudit.encrypted_attributes, :previous_value

    # データベースから直接取得（暗号化された値）
    encrypted_value = StaffIdentityAudit.connection.execute(
      "SELECT previous_value FROM staff_identity_audits WHERE id = '#{audit.id}' LIMIT 1"
    ).first["previous_value"]

    # 暗号化されているので、元の値と異なるはず
    assert_not_equal plain_text, encrypted_value
  end

  test "previous_value is decrypted when accessed through model" do
    plain_text = '{"name": "old"}'
    audit = StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_event: @audit_event,
      previous_value: plain_text
    )

    # モデルから取得すると復号化されている
    assert_equal plain_text, audit.reload.previous_value
  end

  test "has timestamps" do
    assert_not_nil @audit.created_at
    assert_not_nil @audit.updated_at
  end

  test "staff association loads staff correctly" do
    assert_equal @staff, @audit.staff
  end

  test "staff_identity_audit_event association loads status correctly" do
    assert_equal @audit_event, @audit.staff_identity_audit_event
  end

  test "requires staff" do
    audit = StaffIdentityAudit.new(
      staff_identity_audit_event: @audit_event
    )

    assert_not audit.valid?
    assert_not_empty audit.errors[:staff]
  end

  test "requires staff_identity_audit_event" do
    audit = StaffIdentityAudit.new(
      staff: @staff
    )

    assert_not audit.valid?
    assert_not_empty audit.errors[:staff_identity_audit_event]
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
      actor: actor_staff
    )

    assert_equal actor_staff.id, audit.actor_id
    assert_equal "Staff", audit.actor_type
    assert_equal actor_staff, audit.actor
  end

  test "User and Staff can both be actors in different audits" do
    actor_user = users(:one)
    actor_staff = staffs(:one)

    # 同じ staff に対する複数の audit で、異なるアクターを持つ
    StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_event: @audit_event,
      actor: actor_user
    )

    StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_event: @audit_event,
      actor: actor_staff
    )

    # 同じ Staff に関連する複数の audit を取得
    user_actors = @staff.staff_identity_audits.where(actor_type: "User")
    staff_actors = @staff.staff_identity_audits.where(actor_type: "Staff")

    assert_not_empty user_actors
    assert_not_empty staff_actors
  end
end
