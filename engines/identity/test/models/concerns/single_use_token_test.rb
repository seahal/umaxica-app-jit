# typed: false
# frozen_string_literal: true

require "test_helper"

class SingleUseTokenTest < ActiveSupport::TestCase
  fixtures :app_preference_statuses

  class DummySingleUseToken < PrincipalRecord
    include ::PublicId
    include SingleUseToken

    self.table_name = "app_preferences"

    belongs_to :app_preference_status, foreign_key: :status_id
  end

  setup do
    @status = app_preference_statuses(:nothing)
  end

  # ---------------------------------------------------------------------------
  # A. Normal cases
  # ---------------------------------------------------------------------------

  test "generate_refresh_token creates valid token with separator" do
    public_id = "test_public_id_123"
    raw_token, verifier = DummySingleUseToken.generate_refresh_token(public_id: public_id)

    assert_not_nil raw_token
    assert_not_nil verifier
    assert_includes raw_token, ".", "Token should contain separator"
    assert_equal "#{public_id}.#{verifier}", raw_token
  end

  test "parse_refresh_token extracts public_id and verifier" do
    token = "public123.verifier456"
    result = DummySingleUseToken.parse_refresh_token(token)

    assert_equal ["public123", "verifier456"], result
  end

  test "parse_refresh_token returns nil for blank token" do
    assert_nil DummySingleUseToken.parse_refresh_token("")
    assert_nil DummySingleUseToken.parse_refresh_token(nil)
  end

  test "parse_refresh_token returns nil when separator is missing" do
    assert_nil DummySingleUseToken.parse_refresh_token("noseparatortoken")
  end

  # ---------------------------------------------------------------------------
  # B. Scopes
  # ---------------------------------------------------------------------------

  test "active scope excludes revoked and compromised tokens" do
    token = DummySingleUseToken.create!(
      status_id: @status.id,
      jti: SecureRandom.uuid,
      device_id: SecureRandom.uuid,
      device_id_digest: "digest123",
      expires_at: 1.day.from_now,
    )

    assert_includes DummySingleUseToken.active, token

    token.update!(revoked_at: Time.current)

    assert_not_includes DummySingleUseToken.active.reload, token
  end

  test "unconsumed scope excludes used tokens" do
    token = DummySingleUseToken.create!(
      status_id: @status.id,
      jti: SecureRandom.uuid,
      device_id: SecureRandom.uuid,
      device_id_digest: "digest123",
      expires_at: 1.day.from_now,
      used_at: nil,
    )

    assert_includes DummySingleUseToken.unconsumed, token

    token.update!(used_at: Time.current)

    assert_not_includes DummySingleUseToken.unconsumed.reload, token
  end

  # ---------------------------------------------------------------------------
  # C. consume_once_by_digest!
  # ---------------------------------------------------------------------------

  test "consume_once_by_digest! consumes and returns token" do
    token = DummySingleUseToken.create!(
      status_id: @status.id,
      jti: SecureRandom.uuid,
      device_id: SecureRandom.uuid,
      device_id_digest: "digest123",
      expires_at: 1.day.from_now,
    )
    _raw_token, verifier = DummySingleUseToken.generate_refresh_token(public_id: token.public_id)
    digest = DummySingleUseToken.digest_refresh_token(verifier)
    token.update!(token_digest: digest)

    consumed = DummySingleUseToken.consume_once_by_digest!(digest: digest)

    assert_not_nil consumed
    assert_equal token.id, consumed.id
    assert_not_nil consumed.used_at
  end

  test "consume_once_by_digest! returns nil when digest is blank" do
    assert_nil DummySingleUseToken.consume_once_by_digest!(digest: "")
    assert_nil DummySingleUseToken.consume_once_by_digest!(digest: nil)
  end

  test "consume_once_by_digest! returns nil when token already used" do
    token = DummySingleUseToken.create!(
      status_id: @status.id,
      jti: SecureRandom.uuid,
      device_id: SecureRandom.uuid,
      device_id_digest: "digest123",
      expires_at: 1.day.from_now,
      used_at: Time.current,
    )
    _raw_token, verifier = DummySingleUseToken.generate_refresh_token(public_id: token.public_id)
    digest = DummySingleUseToken.digest_refresh_token(verifier)
    token.update!(token_digest: digest)

    assert_nil DummySingleUseToken.consume_once_by_digest!(digest: digest)
  end

  test "consume_once_by_digest! returns nil when token is revoked" do
    token = DummySingleUseToken.create!(
      status_id: @status.id,
      jti: SecureRandom.uuid,
      device_id: SecureRandom.uuid,
      device_id_digest: "digest123",
      expires_at: 1.day.from_now,
      revoked_at: Time.current,
    )
    _raw_token, verifier = DummySingleUseToken.generate_refresh_token(public_id: token.public_id)
    digest = DummySingleUseToken.digest_refresh_token(verifier)
    token.update!(token_digest: digest)

    assert_nil DummySingleUseToken.consume_once_by_digest!(digest: digest)
  end

  test "consume_once_by_digest! returns nil when token is expired" do
    token = DummySingleUseToken.create!(
      status_id: @status.id,
      jti: SecureRandom.uuid,
      device_id: SecureRandom.uuid,
      device_id_digest: "digest123",
      expires_at: 1.hour.ago,
    )
    _raw_token, verifier = DummySingleUseToken.generate_refresh_token(public_id: token.public_id)
    digest = DummySingleUseToken.digest_refresh_token(verifier)
    token.update!(token_digest: digest)

    assert_nil DummySingleUseToken.consume_once_by_digest!(digest: digest)
  end

  # ---------------------------------------------------------------------------
  # D. rotate!
  # ---------------------------------------------------------------------------

  test "rotate! creates replacement token" do
    original = DummySingleUseToken.create!(
      status_id: @status.id,
      jti: SecureRandom.uuid,
      device_id: SecureRandom.uuid,
      device_id_digest: "digest123",
      expires_at: 1.day.from_now,
    )
    _raw_token, verifier = DummySingleUseToken.generate_refresh_token(public_id: original.public_id)
    digest = DummySingleUseToken.digest_refresh_token(verifier)
    original.update!(token_digest: digest)

    replacement = DummySingleUseToken.rotate!(
      presented_digest: digest,
      device_id: original.device_id,
    )

    assert_not_nil replacement
    assert_not_equal original.id, replacement.id
    assert_not_nil replacement.issued_refresh_token
  end

  test "rotate! returns nil when token cannot be consumed" do
    assert_nil DummySingleUseToken.rotate!(
      presented_digest: "nonexistent",
      device_id: "some_device",
    )
  end

  test "rotate! uses new device_id when provided" do
    original = DummySingleUseToken.create!(
      status_id: @status.id,
      jti: SecureRandom.uuid,
      device_id: SecureRandom.uuid,
      device_id_digest: "digest123",
      expires_at: 1.day.from_now,
    )
    _raw_token, verifier = DummySingleUseToken.generate_refresh_token(public_id: original.public_id)
    digest = DummySingleUseToken.digest_refresh_token(verifier)
    original.update!(token_digest: digest)

    new_device_id = "new_device_123"
    replacement = DummySingleUseToken.rotate!(
      presented_digest: digest,
      device_id: new_device_id,
    )

    assert_equal new_device_id, replacement.device_id
  end

  # ---------------------------------------------------------------------------
  # E. State methods
  # ---------------------------------------------------------------------------

  test "replay? returns true when used_at is set" do
    token = DummySingleUseToken.new(used_at: Time.current)

    assert_predicate token, :replay?
  end

  test "replay? returns false when used_at is nil" do
    token = DummySingleUseToken.new(used_at: nil)

    assert_not token.replay?
  end

  test "revoked? returns true when revoked_at is set" do
    token = DummySingleUseToken.new(revoked_at: Time.current)

    assert_predicate token, :revoked?
  end

  test "revoked? returns true when compromised_at is set" do
    token = DummySingleUseToken.new(compromised_at: Time.current)

    assert_predicate token, :revoked?
  end

  test "revoked? returns false when neither revoked nor compromised" do
    token = DummySingleUseToken.new

    assert_not token.revoked?
  end

  # ---------------------------------------------------------------------------
  # F. issued_refresh_token attribute
  # ---------------------------------------------------------------------------

  test "issued_refresh_token can be set and retrieved" do
    token = DummySingleUseToken.new
    raw_token = "test_token_123"

    token.issued_refresh_token = raw_token

    assert_equal raw_token, token.issued_refresh_token
  end
end
