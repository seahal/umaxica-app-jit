# frozen_string_literal: true

# == Schema Information
#
# Table name: user_audit_events
# Database name: activity
#
#  id :bigint           not null, primary key
#

require "test_helper"

class UserAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = UserAuditEvent
    @valid_id = UserAuditEvent::LOGGED_IN
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = UserAuditEvent.new(id: 9)
    assert_predicate record, :valid?
  end

  test "all constants are defined with correct values" do
    assert_equal 1, UserAuditEvent::ACCOUNT_RECOVERED
    assert_equal 2, UserAuditEvent::ACCOUNT_WITHDRAWN
    assert_equal 3, UserAuditEvent::AUTHORIZATION_FAILED
    assert_equal 4, UserAuditEvent::LOGGED_IN
    assert_equal 5, UserAuditEvent::LOGGED_OUT
    assert_equal 6, UserAuditEvent::LOGIN_FAILED
    assert_equal 7, UserAuditEvent::LOGIN_SUCCESS
    assert_equal 8, UserAuditEvent::LOGOUT
    assert_equal 9, UserAuditEvent::NEYO
    assert_equal 10, UserAuditEvent::NON_EXISTENT_EVENT
    assert_equal 11, UserAuditEvent::PASSKEY_REGISTERED
    assert_equal 12, UserAuditEvent::PASSKEY_REMOVED
    assert_equal 13, UserAuditEvent::RECOVERY_CODES_GENERATED
    assert_equal 14, UserAuditEvent::RECOVERY_CODE_USED
    assert_equal 15, UserAuditEvent::SIGNED_UP_WITH_APPLE
    assert_equal 16, UserAuditEvent::SIGNED_UP_WITH_EMAIL
    assert_equal 17, UserAuditEvent::SIGNED_UP_WITH_GOOGLE
    assert_equal 18, UserAuditEvent::SIGNED_UP_WITH_TELEPHONE
    assert_equal 19, UserAuditEvent::TOKEN_REFRESHED
    assert_equal 20, UserAuditEvent::TOTP_DISABLED
    assert_equal 21, UserAuditEvent::TOTP_ENABLED
    assert_equal 22, UserAuditEvent::USER_SECRET_CREATED
    assert_equal 23, UserAuditEvent::USER_SECRET_REMOVED
    assert_equal 24, UserAuditEvent::USER_SECRET_UPDATED
    assert_equal 25, UserAuditEvent::EMAIL_REMOVED
    assert_equal 26, UserAuditEvent::TELEPHONE_REMOVED
    assert_equal 27, UserAuditEvent::SOCIAL_UNLINKED
  end

  test "record_timestamps is disabled" do
    assert_not UserAuditEvent.record_timestamps
  end

  test "DEFAULTS array contains all event IDs" do
    assert_kind_of Array, UserAuditEvent::DEFAULTS
    assert_equal 27, UserAuditEvent::DEFAULTS.size
    assert_includes UserAuditEvent::DEFAULTS, UserAuditEvent::LOGGED_IN
    assert_includes UserAuditEvent::DEFAULTS, UserAuditEvent::LOGIN_SUCCESS
    assert_includes UserAuditEvent::DEFAULTS, UserAuditEvent::TOKEN_REFRESHED
  end

  test "ensure_defaults! creates records" do
    UserAuditEvent.delete_all
    assert_difference("UserAuditEvent.count", 27) do
      UserAuditEvent.ensure_defaults!
    end
    assert UserAuditEvent.exists?(id: UserAuditEvent::LOGGED_IN)
  end

  test "ordered scope returns ordered records" do
    UserAuditEvent.ensure_defaults!
    events = UserAuditEvent.ordered
    assert_kind_of ActiveRecord::Relation, events
    ordered_ids = events.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end

  test "has_many association with user_audits" do
    association = UserAuditEvent.reflect_on_association(:user_audits)
    assert_equal :has_many, association.macro
    assert_equal :restrict_with_error, association.options[:dependent]
    assert_equal :event_id, association.options[:foreign_key]
  end
end
