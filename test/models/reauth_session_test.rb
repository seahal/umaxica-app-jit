# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: reauth_sessions
# Database name: token
#
#  id            :bigint           not null, primary key
#  actor_type    :string           not null
#  attempt_count :integer          default(0), not null
#  expires_at    :datetime         not null
#  method        :string           not null
#  return_to     :text             not null
#  scope         :string           not null
#  status        :string           not null
#  verified_at   :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  actor_id      :bigint           not null
#
# Indexes
#
#  index_reauth_sessions_on_actor_type_and_actor_id_and_status  (actor_type,actor_id,status)
#  index_reauth_sessions_on_expires_at                          (expires_at)
#

require "test_helper"

class ReauthSessionTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: UserStatus::NOTHING)
  end

  test "should be valid with required attributes" do
    session = ReauthSession.new(
      actor: @user,
      method: "passkey",
      status: "PENDING",
      scope: "sensitive_operation",
      return_to: "/settings",
      expires_at: 15.minutes.from_now,
    )

    assert_predicate session, :valid?
  end

  test "should require actor" do
    session = ReauthSession.new(
      method: "passkey",
      status: "PENDING",
      scope: "sensitive_operation",
      return_to: "/settings",
      expires_at: 15.minutes.from_now,
    )

    assert_not session.valid?
    assert_not_empty session.errors[:actor]
  end

  test "should require method" do
    session = ReauthSession.new(
      actor: @user,
      status: "PENDING",
      scope: "sensitive_operation",
      return_to: "/settings",
      expires_at: 15.minutes.from_now,
    )

    assert_not session.valid?
    assert_not_empty session.errors[:method]
  end

  test "should require status" do
    session = ReauthSession.new(
      actor: @user,
      method: "passkey",
      scope: "sensitive_operation",
      return_to: "/settings",
      expires_at: 15.minutes.from_now,
    )

    assert_not session.valid?
    assert_not_empty session.errors[:status]
  end

  test "should require scope" do
    session = ReauthSession.new(
      actor: @user,
      method: "passkey",
      status: "PENDING",
      return_to: "/settings",
      expires_at: 15.minutes.from_now,
    )

    assert_not session.valid?
    assert_not_empty session.errors[:scope]
  end

  test "should require return_to" do
    session = ReauthSession.new(
      actor: @user,
      method: "passkey",
      status: "PENDING",
      scope: "sensitive_operation",
      expires_at: 15.minutes.from_now,
    )

    assert_not session.valid?
    assert_not_empty session.errors[:return_to]
  end

  test "should require expires_at" do
    session = ReauthSession.new(
      actor: @user,
      method: "passkey",
      status: "PENDING",
      scope: "sensitive_operation",
      return_to: "/settings",
    )

    assert_not session.valid?
    assert_not_empty session.errors[:expires_at]
  end

  test "method must be in allowed METHODS list" do
    valid_methods = ReauthSession::METHODS

    valid_methods.each do |method|
      session = ReauthSession.new(
        actor: @user,
        method: method,
        status: "PENDING",
        scope: "test",
        return_to: "/test",
        expires_at: 15.minutes.from_now,
      )

      assert_predicate session, :valid?, "Expected #{method} to be valid"
    end

    invalid_session = ReauthSession.new(
      actor: @user,
      method: "invalid_method",
      status: "PENDING",
      scope: "test",
      return_to: "/test",
      expires_at: 15.minutes.from_now,
    )

    assert_not invalid_session.valid?
    assert_not_empty invalid_session.errors[:method]
  end

  test "status must be in allowed STATUSES list" do
    valid_statuses = ReauthSession::STATUSES

    valid_statuses.each do |status|
      session = ReauthSession.new(
        actor: @user,
        method: "passkey",
        status: status,
        scope: "test",
        return_to: "/test",
        expires_at: 15.minutes.from_now,
      )

      assert_predicate session, :valid?, "Expected #{status} to be valid"
    end

    invalid_session = ReauthSession.new(
      actor: @user,
      method: "passkey",
      status: "INVALID_STATUS",
      scope: "test",
      return_to: "/test",
      expires_at: 15.minutes.from_now,
    )

    assert_not invalid_session.valid?
    assert_not_empty invalid_session.errors[:status]
  end

  test "attempt_count must be greater than or equal to zero" do
    session = ReauthSession.new(
      actor: @user,
      method: "passkey",
      status: "PENDING",
      scope: "test",
      return_to: "/test",
      expires_at: 15.minutes.from_now,
      attempt_count: -1,
    )

    assert_not session.valid?
    assert_not_empty session.errors[:attempt_count]
  end

  test "attempt_count zero is valid at lower boundary" do
    session = ReauthSession.new(
      actor: @user,
      method: "passkey",
      status: "PENDING",
      scope: "test",
      return_to: "/test",
      expires_at: 15.minutes.from_now,
      attempt_count: 0,
    )

    assert_predicate session, :valid?
  end

  test "expired? returns false one second before expires_at" do
    freeze_time do
      session = ReauthSession.create!(
        actor: @user,
        method: "passkey",
        status: "PENDING",
        scope: "test",
        return_to: "/test",
        expires_at: 1.second.from_now,
      )

      assert_not session.expired?
    end
  end

  test "expired? returns true at exact expires_at" do
    freeze_time do
      expires_at = Time.current
      session = ReauthSession.new(
        actor: @user,
        method: "passkey",
        status: "PENDING",
        scope: "test",
        return_to: "/test",
        expires_at: expires_at,
      )

      assert_predicate session, :expired?
    end
  end

  test "expired? returns true after expires_at" do
    session = ReauthSession.new(
      actor: @user,
      method: "passkey",
      status: "PENDING",
      scope: "test",
      return_to: "/test",
      expires_at: 1.minute.ago,
    )

    assert_predicate session, :expired?
  end

  test "for_actor scope returns sessions for given actor" do
    user2 = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: UserStatus::NOTHING)

    session1 = ReauthSession.create!(
      actor: @user,
      method: "passkey",
      status: "PENDING",
      scope: "test",
      return_to: "/test",
      expires_at: 15.minutes.from_now,
    )

    session2 = ReauthSession.create!(
      actor: @user,
      method: "totp",
      status: "PENDING",
      scope: "test2",
      return_to: "/test2",
      expires_at: 15.minutes.from_now,
    )

    ReauthSession.create!(
      actor: user2,
      method: "passkey",
      status: "PENDING",
      scope: "test3",
      return_to: "/test3",
      expires_at: 15.minutes.from_now,
    )

    actor_sessions = ReauthSession.for_actor(@user)

    assert_includes actor_sessions, session1
    assert_includes actor_sessions, session2
    assert_equal 2, actor_sessions.count
  end

  test "pending scope returns only pending sessions" do
    ReauthSession.create!(
      actor: @user,
      method: "passkey",
      status: "PENDING",
      scope: "test1",
      return_to: "/test1",
      expires_at: 15.minutes.from_now,
    )

    ReauthSession.create!(
      actor: @user,
      method: "passkey",
      status: "VERIFIED",
      scope: "test2",
      return_to: "/test2",
      expires_at: 15.minutes.from_now,
    )

    ReauthSession.create!(
      actor: @user,
      method: "passkey",
      status: "PENDING",
      scope: "test3",
      return_to: "/test3",
      expires_at: 15.minutes.from_now,
    )

    pending_sessions = ReauthSession.pending

    assert_equal 2, pending_sessions.count
    pending_sessions.each do |session|
      assert_equal "PENDING", session.status
    end
  end

  test "belongs to polymorphic actor" do
    session = ReauthSession.create!(
      actor: @user,
      method: "passkey",
      status: "PENDING",
      scope: "test",
      return_to: "/test",
      expires_at: 15.minutes.from_now,
    )

    assert_equal @user, session.actor
    assert_equal "User", session.actor_type
  end

  test "STATUSES constant contains expected values" do
    expected_statuses = %w(PENDING VERIFIED CANCELLED EXPIRED)

    assert_equal expected_statuses, ReauthSession::STATUSES
  end

  test "METHODS constant contains expected values" do
    expected_methods = %w(passkey totp email_otp)

    assert_equal expected_methods, ReauthSession::METHODS
  end
end
