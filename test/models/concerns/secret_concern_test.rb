# frozen_string_literal: true

require "test_helper"

class SecretConcernTest < ActiveSupport::TestCase
  class DummySecret < PrincipalRecord
    self.table_name = "user_secrets"
    include Secret

    belongs_to :user
    alias_attribute :user_secret_status_id, :user_identity_secret_status_id

    def self.identity_secret_status_class
      UserSecretStatus
    end

    def self.identity_secret_status_id_column
      :user_identity_secret_status_id
    end
  end

  setup do
    @user = User.find_by!(public_id: "one_id")
    # Ensure statuses exist
    UserSecretStatus.find_or_create_by!(id: "ACTIVE")
    UserSecretStatus.find_or_create_by!(id: "USED")
    UserSecretStatus.find_or_create_by!(id: "EXPIRED")
    UserSecretStatus.find_or_create_by!(id: "REVOKED")
    # Ensure kinds exist
    UserSecretKind.find_or_create_by!(id: "UNLIMITED")
  end

  test "issue! creates a new record with raw secret" do
    record, raw = DummySecret.issue!(name: "Test Secret", user: @user, user_secret_kind_id: "UNLIMITED")
    assert_instance_of DummySecret, record
    assert_predicate record, :persisted?
    assert_equal 36, raw.length
    assert_equal "ACTIVE", record.user_secret_status_id
  end

  test "verify_and_consume! returns true on valid secret" do
    record, raw = DummySecret.issue!(name: "One Time", user: @user, uses: 1, user_secret_kind_id: "UNLIMITED")
    assert record.verify_and_consume!(raw)
    assert_predicate record.reload, :used?
    assert_equal 0, record.uses_remaining
  end

  test "verify_and_consume! returns false on invalid secret" do
    record, _raw = DummySecret.issue!(name: "One Time", user: @user, user_secret_kind_id: "UNLIMITED")
    assert_not record.verify_and_consume!("wrong_secret")
    assert_predicate record.reload, :active?
  end

  test "verify_and_consume! returns false when not active" do
    record, raw = DummySecret.issue!(name: "Inactive", user: @user, status: :revoked, user_secret_kind_id: "UNLIMITED")
    assert_not record.verify_and_consume!(raw)
  end

  test "verify_and_consume! returns false when expired" do
    record, raw = DummySecret.issue!(name: "Expired", user: @user, expires_at: 1.hour.ago, user_secret_kind_id: "UNLIMITED")
    assert_not record.verify_and_consume!(raw)
    assert_predicate record.reload, :expired?
  end

  test "verify_and_consume! allows multiple uses" do
    record, raw = DummySecret.issue!(name: "Multi", user: @user, uses: 2, user_secret_kind_id: "UNLIMITED")
    assert record.verify_and_consume!(raw)
    assert_predicate record.reload, :active?
    assert_equal 1, record.uses_remaining

    assert record.verify_and_consume!(raw)
    assert_predicate record.reload, :used?
    assert_equal 0, record.uses_remaining
  end

  test "status predicates" do
    record = DummySecret.new(user_secret_status_id: "ACTIVE")
    assert_predicate record, :active?
    record.user_secret_status_id = "USED"
    assert_predicate record, :used?
    record.user_secret_status_id = "REVOKED"
    assert_predicate record, :revoked?
    record.user_secret_status_id = "EXPIRED"
    assert_predicate record, :expired?
    record.user_secret_status_id = "DELETED"
    assert_predicate record, :deleted?
  end

  test "expired_by_time? handles Float::INFINITY" do
    record = DummySecret.new(expires_at: Float::INFINITY)
    assert_not record.send(:expired_by_time?, Time.current)

    record.expires_at = -Float::INFINITY
    assert_not record.send(:expired_by_time?, Time.current)
  end
end
