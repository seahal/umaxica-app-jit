require "test_helper"

class StaffIdentityAuditTest < ActiveSupport::TestCase
  def setup
    @staff = staffs(:one)
    @audit_status = staff_identity_audit_statuses(:one)
    @audit = StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_status: @audit_status,
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

  test "belongs to staff_identity_audit_status" do
    association = StaffIdentityAudit.reflect_on_association(:staff_identity_audit_status)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "can be created with staff and status" do
    assert_not_nil @audit
    assert_equal @staff.id, @audit.staff_id
    assert_equal @audit_status.id, @audit.status_id
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
      staff_identity_audit_status: @audit_status
    )

    assert_nil audit_without_actor.actor_id
  end

  test "previous_value can be stored" do
    audit = StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_status: @audit_status,
      previous_value: '{"name": "old"}'
    )

    assert_equal '{"name": "old"}', audit.previous_value
  end

  test "current_value can be stored" do
    audit = StaffIdentityAudit.create!(
      staff: @staff,
      staff_identity_audit_status: @audit_status,
      current_value: '{"name": "new"}'
    )

    assert_equal '{"name": "new"}', audit.current_value
  end

  test "has timestamps" do
    assert_not_nil @audit.created_at
    assert_not_nil @audit.updated_at
  end

  test "staff association loads staff correctly" do
    assert_equal @staff, @audit.staff
  end

  test "staff_identity_audit_status association loads status correctly" do
    assert_equal @audit_status, @audit.staff_identity_audit_status
  end

  test "requires staff" do
    audit = StaffIdentityAudit.new(
      staff_identity_audit_status: @audit_status
    )

    assert_not audit.valid?
    assert_not_empty audit.errors[:staff]
  end

  test "requires staff_identity_audit_status" do
    audit = StaffIdentityAudit.new(
      staff: @staff
    )

    assert_not audit.valid?
    assert_not_empty audit.errors[:staff_identity_audit_status]
  end
end
