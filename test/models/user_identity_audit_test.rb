require "test_helper"

class UserIdentityAuditTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @audit_event = user_identity_audit_events(:one)
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

    assert_nil audit_without_actor.actor_id
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

    # モデルの encrypted_attributes に previous_value が含まれていることを確認
    assert_includes UserIdentityAudit.encrypted_attributes, :previous_value

    # データベースから直接取得（暗号化された値）
    encrypted_value = UserIdentityAudit.connection.execute(
      "SELECT previous_value FROM user_identity_audits WHERE id = '#{audit.id}' LIMIT 1"
    ).first["previous_value"]

    # 暗号化されているので、元の値と異なるはず
    assert_not_equal plain_text, encrypted_value
  end

  test "previous_value is decrypted when accessed through model" do
    plain_text = '{"email": "old@example.com"}'
    audit = UserIdentityAudit.create!(
      user: @user,
      user_identity_audit_event: @audit_event,
      previous_value: plain_text
    )

    # モデルから取得すると復号化されている
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

    assert_not audit.valid?
    assert_not_empty audit.errors[:user_identity_audit_event]
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

    # 同じ user に対する複数の audit で、異なるアクターを持つ
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

    # 同じ User に関連する複数の audit を取得
    user_actors = @user.user_identity_audits.where(actor_type: "User")
    staff_actors = @user.user_identity_audits.where(actor_type: "Staff")

    assert_not_empty user_actors
    assert_not_empty staff_actors
  end
end
