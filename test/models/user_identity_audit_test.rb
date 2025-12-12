require "test_helper"

class UserIdentityAuditTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @audit_status = user_identity_audit_statuses(:one)
    @audit = UserIdentityAudit.create!(
      user: @user,
      user_identity_audit_status: @audit_status,
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

  test "belongs to user_identity_audit_status" do
    association = UserIdentityAudit.reflect_on_association(:user_identity_audit_status)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "can be created with user and status" do
    assert_not_nil @audit
    assert_equal @user.id, @audit.user_id
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
    audit_without_actor = UserIdentityAudit.create!(
      user: @user,
      user_identity_audit_status: @audit_status
    )

    assert_nil audit_without_actor.actor_id
  end

  test "previous_value can be stored" do
    audit = UserIdentityAudit.create!(
      user: @user,
      user_identity_audit_status: @audit_status,
      previous_value: '{"email": "old@example.com"}'
    )

    assert_equal '{"email": "old@example.com"}', audit.previous_value
  end

  test "current_value can be stored" do
    audit = UserIdentityAudit.create!(
      user: @user,
      user_identity_audit_status: @audit_status,
      current_value: '{"email": "new@example.com"}'
    )

    assert_equal '{"email": "new@example.com"}', audit.current_value
  end

  test "has timestamps" do
    assert_not_nil @audit.created_at
    assert_not_nil @audit.updated_at
  end

  test "user association loads user correctly" do
    assert_equal @user, @audit.user
  end

  test "user_identity_audit_status association loads status correctly" do
    assert_equal @audit_status, @audit.user_identity_audit_status
  end

  test "requires user" do
    audit = UserIdentityAudit.new(
      user_identity_audit_status: @audit_status
    )

    assert_not audit.valid?
    assert_not_empty audit.errors[:user]
  end

  test "requires user_identity_audit_status" do
    audit = UserIdentityAudit.new(
      user: @user
    )

    assert_not audit.valid?
    assert_not_empty audit.errors[:user_identity_audit_status]
  end

  test "validates foreign key constraint on status_id" do
    audit = UserIdentityAudit.new(
      user: @user,
      status_id: "NON_EXISTENT_STATUS",
      timestamp: Time.current
    )

    assert_raises ActiveRecord::InvalidForeignKey do
      audit.save!(validate: false)
    end
  end
end
