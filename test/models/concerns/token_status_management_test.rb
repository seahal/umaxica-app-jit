# typed: false
# frozen_string_literal: true

require "test_helper"

class TokenStatusManagementTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: UserStatus::NEYO)
    @token = UserToken.create!(user: @user, user_token_kind_id: UserTokenKind::BROWSER_WEB)
  end

  test "defines status constants" do
    assert_equal "active", TokenStatusManagement::STATUS_ACTIVE
    assert_equal "restricted", TokenStatusManagement::STATUS_RESTRICTED
    assert_equal "revoked", TokenStatusManagement::STATUS_REVOKED
    assert_equal %w(active restricted revoked), TokenStatusManagement::VALID_STATUSES
  end

  test "defines restricted ttl" do
    assert_equal 15.minutes, TokenStatusManagement::RESTRICTED_TTL
  end

  test "active_status scope returns only active non-revoked tokens" do
    @token.update!(status: "active", revoked_at: nil)
    restricted = UserToken.create!(user: @user, status: "restricted")
    revoked = UserToken.create!(user: @user, revoked_at: Time.current)

    results = UserToken.active_status

    assert_includes results, @token
    assert_not_includes results, restricted
    assert_not_includes results, revoked
  end

  test "restricted_status scope returns only restricted non-revoked tokens" do
    active = UserToken.create!(user: @user, status: "active")
    @token.update!(status: "restricted", revoked_at: nil)
    revoked = UserToken.create!(user: @user, status: "restricted", revoked_at: Time.current)

    results = UserToken.restricted_status

    assert_includes results, @token
    assert_not_includes results, active
    assert_not_includes results, revoked
  end

  test "not_revoked scope returns only non-revoked tokens" do
    @token.update!(revoked_at: nil)
    revoked = UserToken.create!(user: @user, revoked_at: Time.current)

    results = UserToken.not_revoked

    assert_includes results, @token
    assert_not_includes results, revoked
  end

  test "restricted? returns true when status is restricted" do
    @token.update!(status: "restricted")

    assert_predicate @token, :restricted?

    @token.update!(status: "active")

    assert_not_predicate @token, :restricted?
  end

  test "active_status? returns true when status is active and not revoked" do
    @token.update!(status: "active", revoked_at: nil)

    assert_predicate @token, :active_status?

    @token.update!(status: "restricted")

    assert_not_predicate @token, :active_status?

    @token.update!(status: "active", revoked_at: Time.current)

    assert_not_predicate @token, :active_status?
  end

  test "mark_restricted! updates status to restricted" do
    @token.update!(status: "active")
    @token.mark_restricted!

    assert_equal "restricted", @token.reload.status
  end

  test "promote_to_active! updates status to active" do
    @token.update!(status: "restricted")
    @token.promote_to_active!

    assert_equal "active", @token.reload.status
  end

  test "revoke! sets revoked_at and status to revoked" do
    freeze_time do
      @token.revoke!

      assert_predicate @token.revoked_at, :present?
      assert_equal Time.current, @token.revoked_at
      assert_equal "revoked", @token.status
    end
  end

  test "validates status inclusion" do
    token = UserToken.new(user: @user, status: "invalid_status")

    assert_not token.valid?
    assert_not_empty token.errors[:status]
  end

  test "validates status length" do
    token = UserToken.new(user: @user, status: "a" * 21)

    assert_not token.valid?
    assert_not_empty token.errors[:status]
  end

  test "default status is active" do
    token = UserToken.new(user: @user)

    assert_equal "active", token.status
  end

  test "works with StaffToken as well" do
    staff = Staff.find_by!(public_id: "bcde3456")
    token = StaffToken.create!(staff: staff)

    assert_predicate token, :active_status?

    token.mark_restricted!

    assert_predicate token, :restricted?

    token.promote_to_active!

    assert_predicate token, :active_status?

    token.revoke!

    assert_equal "revoked", token.reload.status
  end
end
