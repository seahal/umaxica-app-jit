# typed: false
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

  test "constants are grouped and defined" do
    assert_equal [
      UserActivityEvent::ACCOUNT_RECOVERED,
      UserActivityEvent::ACCOUNT_WITHDRAWN,
      UserActivityEvent::AUTHORIZATION_FAILED,
      UserActivityEvent::LOGGED_IN,
      UserActivityEvent::LOGGED_OUT,
      UserActivityEvent::LOGIN_FAILED,
      UserActivityEvent::LOGIN_SUCCESS,
      UserActivityEvent::LOGOUT,
      UserActivityEvent::NOTHING,
      UserActivityEvent::NON_EXISTENT_EVENT,
      UserActivityEvent::PASSKEY_REGISTERED,
      UserActivityEvent::PASSKEY_REMOVED,
      UserActivityEvent::RECOVERY_CODES_GENERATED,
      UserActivityEvent::RECOVERY_CODE_USED,
      UserActivityEvent::SIGNED_UP_WITH_APPLE,
      UserActivityEvent::SIGNED_UP_WITH_EMAIL,
      UserActivityEvent::SIGNED_UP_WITH_GOOGLE,
      UserActivityEvent::SIGNED_UP_WITH_TELEPHONE,
      UserActivityEvent::TOKEN_REFRESHED,
      UserActivityEvent::TOTP_DISABLED,
      UserActivityEvent::TOTP_ENABLED,
      UserActivityEvent::USER_SECRET_CREATED,
      UserActivityEvent::USER_SECRET_REMOVED,
      UserActivityEvent::USER_SECRET_UPDATED,
      UserActivityEvent::EMAIL_REMOVED,
      UserActivityEvent::TELEPHONE_REMOVED,
      UserActivityEvent::SOCIAL_UNLINKED,
      UserActivityEvent::STEP_UP_VERIFIED,
    ], UserActivityEvent::DEFAULTS.sort
  end

  test "record_timestamps is disabled" do
    assert_not UserActivityEvent.record_timestamps
  end

  test "DEFAULTS array contains all event IDs" do
    assert_kind_of Array, UserActivityEvent::DEFAULTS
    assert_equal 28, UserActivityEvent::DEFAULTS.size
    assert_includes UserActivityEvent::DEFAULTS, UserActivityEvent::LOGGED_IN
    assert_includes UserActivityEvent::DEFAULTS, UserActivityEvent::LOGIN_SUCCESS
    assert_includes UserActivityEvent::DEFAULTS, UserActivityEvent::TOKEN_REFRESHED
  end

  test "ensure_defaults! creates records" do
    UserActivityEvent.delete_all
    assert_difference("UserActivityEvent.count", 28) do
      UserActivityEvent.ensure_defaults!
    end
    assert UserActivityEvent.exists?(id: UserActivityEvent::LOGGED_IN)
  end

  test "returns all default records" do
    UserActivityEvent.ensure_defaults!
    ids = UserActivityEvent.pluck(:id)

    assert_empty(UserActivityEvent::DEFAULTS - ids)
  end

  test "has_many association with user_activities" do
    association = UserActivityEvent.reflect_on_association(:user_activities)

    assert_equal :has_many, association.macro
    assert_equal :restrict_with_error, association.options[:dependent]
    assert_equal :event_id, association.options[:foreign_key]
  end
end
