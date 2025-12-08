require "test_helper"

class UserIdentityAuditEventTest < ActiveSupport::TestCase
  def setup
    @audit_event = UserIdentityAuditEvent.new(id: "TEST_EVENT")
  end

  # ID default value tests
  test "default id value is NONE" do
    event = UserIdentityAuditEvent.new

    assert_equal "NONE", event.id
  end

  # ID presence tests
  test "id must be present" do
    @audit_event.id = nil

    assert_not @audit_event.valid?
    assert_not_empty @audit_event.errors[:id]
  end

  test "id cannot be empty string" do
    @audit_event.id = ""

    assert_not @audit_event.valid?
    assert_not_empty @audit_event.errors[:id]
  end

  # ID uniqueness tests
  test "id must be unique" do
    UserIdentityAuditEvent.create!(id: "UNIQUE_EVENT")
    duplicate = UserIdentityAuditEvent.new(id: "UNIQUE_EVENT")

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:id]
  end

  # ID format tests
  test "id must be uppercase and underscores only" do
    @audit_event.id = "invalid_event"

    assert_not @audit_event.valid?
    assert_not_empty @audit_event.errors[:id]
  end

  test "id with lowercase letters is invalid" do
    @audit_event.id = "Test_Event"

    assert_not @audit_event.valid?
    assert_not_empty @audit_event.errors[:id]
  end

  test "id with spaces is invalid" do
    @audit_event.id = "TEST EVENT"

    assert_not @audit_event.valid?
    assert_not_empty @audit_event.errors[:id]
  end

  test "id with special characters is invalid" do
    @audit_event.id = "TEST-EVENT"

    assert_not @audit_event.valid?
    assert_not_empty @audit_event.errors[:id]
  end

  test "id with numbers is invalid" do
    @audit_event.id = "TEST_EVENT_123"

    assert_not @audit_event.valid?
    assert_not_empty @audit_event.errors[:id]
  end

  test "valid id format with uppercase and underscores" do
    @audit_event.id = "VALID_EVENT_NAME"

    assert_predicate @audit_event, :valid?
  end

  test "valid id format with single uppercase letter" do
    @audit_event.id = "A"

    assert_predicate @audit_event, :valid?
  end

  test "valid id format with only underscores and uppercase" do
    @audit_event.id = "A_B_C"

    assert_predicate @audit_event, :valid?
  end

  # ID length tests
  test "id with exactly 255 characters is valid" do
    @audit_event.id = "A" * 255

    assert_predicate @audit_event, :valid?
  end

  test "id with 1 character is valid" do
    @audit_event.id = "A"

    assert_predicate @audit_event, :valid?
  end

  test "id exceeding 255 characters should raise error when saving" do
    long_id = "A" * 256
    assert_raises(ActiveRecord::StatementInvalid) do
      UserIdentityAuditEvent.create!(id: long_id)
    end
  end
end
