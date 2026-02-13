# frozen_string_literal: true

# == Schema Information
#
# Table name: user_activity_events
# Database name: activity
#
#  id :bigint           not null, primary key
#

require "test_helper"

class UserActivityEventTest < ActiveSupport::TestCase
  setup do
    @model_class = UserActivityEvent
    @valid_id = UserActivityEvent::LOGGED_IN
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = UserActivityEvent.new(id: 9)
    assert_predicate record, :valid?
  end

  test "all constants are defined with correct values" do # rubocop:disable Minitest/MultipleAssertions
    assert_equal 1, UserActivityEvent::ACCOUNT_RECOVERED
    assert_equal 2, UserActivityEvent::ACCOUNT_WITHDRAWN
    assert_equal 3, UserActivityEvent::AUTHORIZATION_FAILED
    assert_equal 4, UserActivityEvent::LOGGED_IN
    assert_equal 5, UserActivityEvent::LOGGED_OUT
    assert_equal 6, UserActivityEvent::LOGIN_FAILED
    assert_equal 7, UserActivityEvent::LOGIN_SUCCESS
    assert_equal 8, UserActivityEvent::LOGOUT
    assert_equal 9, UserActivityEvent::NEYO
    assert_equal 10, UserActivityEvent::NON_EXISTENT_EVENT
    assert_equal 11, UserActivityEvent::PASSKEY_REGISTERED
    assert_equal 12, UserActivityEvent::PASSKEY_REMOVED
    assert_equal 13, UserActivityEvent::RECOVERY_CODES_GENERATED
    assert_equal 14, UserActivityEvent::RECOVERY_CODE_USED
    assert_equal 15, UserActivityEvent::SIGNED_UP_WITH_APPLE
    assert_equal 16, UserActivityEvent::SIGNED_UP_WITH_EMAIL
    assert_equal 17, UserActivityEvent::SIGNED_UP_WITH_GOOGLE
    assert_equal 18, UserActivityEvent::SIGNED_UP_WITH_TELEPHONE
    assert_equal 19, UserActivityEvent::TOKEN_REFRESHED
    assert_equal 20, UserActivityEvent::TOTP_DISABLED
    assert_equal 21, UserActivityEvent::TOTP_ENABLED
    assert_equal 22, UserActivityEvent::USER_SECRET_CREATED
    assert_equal 23, UserActivityEvent::USER_SECRET_REMOVED
    assert_equal 24, UserActivityEvent::USER_SECRET_UPDATED
    assert_equal 25, UserActivityEvent::EMAIL_REMOVED
    assert_equal 26, UserActivityEvent::TELEPHONE_REMOVED
    assert_equal 27, UserActivityEvent::SOCIAL_UNLINKED
  end

  test "record_timestamps is disabled" do
    assert_not UserActivityEvent.record_timestamps
  end

  test "DEFAULTS array contains all event IDs" do
    assert_kind_of Array, UserActivityEvent::DEFAULTS
    assert_equal 27, UserActivityEvent::DEFAULTS.size
    assert_includes UserActivityEvent::DEFAULTS, UserActivityEvent::LOGGED_IN
    assert_includes UserActivityEvent::DEFAULTS, UserActivityEvent::LOGIN_SUCCESS
    assert_includes UserActivityEvent::DEFAULTS, UserActivityEvent::TOKEN_REFRESHED
  end

  test "ensure_defaults! creates records" do
    UserActivityEvent.delete_all
    assert_difference("UserActivityEvent.count", 27) do
      UserActivityEvent.ensure_defaults!
    end
    assert UserActivityEvent.exists?(id: UserActivityEvent::LOGGED_IN)
  end

  test "ordered scope returns ordered records" do
    UserActivityEvent.ensure_defaults!
    events = UserActivityEvent.ordered
    assert_kind_of ActiveRecord::Relation, events
    ordered_ids = events.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end

  test "has_many association with user_activities" do
    association = UserActivityEvent.reflect_on_association(:user_activities)
    assert_equal :has_many, association.macro
    assert_equal :restrict_with_error, association.options[:dependent]
    assert_equal :event_id, association.options[:foreign_key]
  end
end
