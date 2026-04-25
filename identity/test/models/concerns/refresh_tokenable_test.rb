# typed: false
# frozen_string_literal: true

require "test_helper"

class RefreshTokenableTest < ActiveSupport::TestCase
  fixtures :user_token_statuses, :user_token_kinds, :users

  class DummyRefreshToken < TokenRecord
    include ::PublicId
    include RefreshTokenable

    self.table_name = "user_tokens"

    belongs_to :user
    belongs_to :user_token_status
    belongs_to :user_token_kind

    def self.expiry_column
      :expired_at
    end
  end

  setup do
    @user = users(:one)
    @status = user_token_statuses(:ACTIVE)
    @kind = user_token_kinds(:browser_web)
  end

  # ---------------------------------------------------------------------------
  # A. Normal cases
  # ---------------------------------------------------------------------------

  test "refresh_tokenable sets default values on create" do
    token = DummyRefreshToken.create!(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
    )

    assert_not_nil token.refresh_expires_at
    assert_not_nil token.refresh_token_family_id
    assert_equal 0, token.refresh_token_generation
    assert_not_nil token.device_id
    assert_not_nil token.device_id_digest
  end

  test "rotate_refresh_token! generates new refresh token and updates digest" do
    token = DummyRefreshToken.create!(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
    )
    original_digest = token.refresh_token_digest

    raw_token = token.rotate_refresh_token!

    token.reload

    assert_not_equal original_digest, token.refresh_token_digest
    assert_not_nil raw_token
    assert_includes raw_token, ".", "Raw token should contain separator"
    assert_equal 1, token.refresh_token_generation
    assert_not_nil token.last_used_at
  end

  test "rotate_refresh_token! accepts custom expires_at" do
    token = DummyRefreshToken.create!(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
    )
    custom_expires = 1.day.from_now

    token.rotate_refresh_token!(expires_at: custom_expires)

    token.reload

    assert_equal custom_expires.to_i, token.refresh_expires_at.to_i
  end

  # ---------------------------------------------------------------------------
  # B. State tests
  # ---------------------------------------------------------------------------

  test "active? returns true for non-expired, non-revoked token" do
    token = DummyRefreshToken.create!(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
      refresh_expires_at: 1.day.from_now,
    )

    assert_predicate token, :active?
    assert_not token.revoked?
    assert_not token.expired_refresh?
  end

  test "revoked? returns true when compromised" do
    token = DummyRefreshToken.create!(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
      compromised_at: Time.current,
    )

    assert_predicate token, :revoked?
    assert_not token.active?
  end

  test "expired_refresh? returns true when refresh_expires_at is past" do
    token = DummyRefreshToken.create!(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
      refresh_expires_at: 1.hour.ago,
    )

    assert_predicate token, :expired_refresh?
    assert_not token.active?
  end

  test "expired? returns true when expired_at is set" do
    token = DummyRefreshToken.create!(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
      expired_at: Time.current,
    )

    assert_predicate token, :expired?
  end

  # ---------------------------------------------------------------------------
  # C. Authentication tests
  # ---------------------------------------------------------------------------

  test "authenticate_refresh_token returns true with matching verifier" do
    token = DummyRefreshToken.create!(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
    )
    _, verifier = token.generate_refresh_token(public_id: token.public_id)
    token.update!(refresh_token_digest: token.digest_refresh_token(verifier))

    assert token.authenticate_refresh_token(verifier)
  end

  test "authenticate_refresh_token returns false with wrong verifier" do
    token = DummyRefreshToken.create!(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
    )
    _, verifier = token.generate_refresh_token(public_id: token.public_id)
    token.update!(refresh_token_digest: token.digest_refresh_token(verifier))

    assert_not token.authenticate_refresh_token("wrong_verifier")
  end

  test "authenticate_refresh_token returns false when token is revoked" do
    token = DummyRefreshToken.create!(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
      compromised_at: Time.current,
    )
    _raw_token, verifier = token.generate_refresh_token(public_id: token.public_id)
    token.update!(refresh_token_digest: token.digest_refresh_token(verifier))

    assert_not token.authenticate_refresh_token(verifier)
  end

  # ---------------------------------------------------------------------------
  # D. Class method: rotate_refresh!
  # ---------------------------------------------------------------------------

  test "rotate_refresh! returns rotated status with valid token" do
    original = DummyRefreshToken.create!(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
    )
    _raw_token, verifier = original.generate_refresh_token(public_id: original.public_id)
    original.update!(refresh_token_digest: original.digest_refresh_token(verifier))

    result = DummyRefreshToken.rotate_refresh!(
      presented_refresh_digest: original.refresh_token_digest,
      device_id: original.device_id,
    )

    assert_equal :rotated, result[:status]
    assert_not_nil result[:token]
    assert_not_nil result[:previous_token]
    assert_not_nil result[:refresh_token]
    assert_equal original.id, result[:previous_token].id
  end

  test "rotate_refresh! returns invalid when token not found" do
    result = DummyRefreshToken.rotate_refresh!(
      presented_refresh_digest: "nonexistent_digest",
      device_id: "some_device",
    )

    assert_equal :invalid, result[:status]
    assert_nil result[:token]
  end

  test "rotate_refresh! returns replay when token already rotated" do
    original = DummyRefreshToken.create!(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
      rotated_at: Time.current,
    )
    _raw_token, verifier = original.generate_refresh_token(public_id: original.public_id)
    original.update!(refresh_token_digest: original.digest_refresh_token(verifier))

    result = DummyRefreshToken.rotate_refresh!(
      presented_refresh_digest: original.refresh_token_digest,
      device_id: original.device_id,
    )

    assert_equal :replay, result[:status]
    assert_not_nil result[:token]
  end

  test "rotate_refresh! returns invalid when device_id mismatch" do
    original = DummyRefreshToken.create!(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
    )
    _raw_token, verifier = original.generate_refresh_token(public_id: original.public_id)
    original.update!(refresh_token_digest: original.digest_refresh_token(verifier))

    result = DummyRefreshToken.rotate_refresh!(
      presented_refresh_digest: original.refresh_token_digest,
      device_id: "different_device_id",
    )

    assert_equal :invalid, result[:status]
  end

  # ---------------------------------------------------------------------------
  # E. Revocation tests
  # ---------------------------------------------------------------------------

  test "revoke! sets expired_at and revoked_at" do
    token = DummyRefreshToken.create!(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
    )

    token.revoke!
    token.reload

    assert_predicate token, :expired?
    assert_not_nil token.expired_at
    assert_not_nil token.revoked_at
  end

  # ---------------------------------------------------------------------------
  # F. Refresh token setter tests
  # ---------------------------------------------------------------------------

  test "refresh_token= sets digest from verifier" do
    token = DummyRefreshToken.new(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
    )
    verifier = "test_verifier_123"

    token.refresh_token = verifier

    assert_equal token.digest_refresh_token(verifier), token.refresh_token_digest
  end

  test "refresh_token= sets nil when blank" do
    token = DummyRefreshToken.new(
      user: @user,
      user_token_status_id: @status.id,
      user_token_kind_id: @kind.id,
    )

    token.refresh_token = ""

    assert_nil token.refresh_token_digest
  end
end
