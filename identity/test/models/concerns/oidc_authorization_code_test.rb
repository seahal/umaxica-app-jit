# typed: false
# frozen_string_literal: true

require "test_helper"

class OidcAuthorizationCodeTest < ActiveSupport::TestCase
  fixtures :users

  setup do
    @user = users(:one)
    @code_challenge = Base64.urlsafe_encode64(
      Digest::SHA256.digest("test_code_verifier_abcdefghijklmnop"),
      padding: false,
    )
  end

  test "subject_association_name defaults from class name" do
    assert_equal :user, UserAuthorizationCode.subject_association_name
  end

  test "generate_code returns urlsafe base64 string" do
    code = UserAuthorizationCode.generate_code

    assert_not_nil code
    assert_match(/\A[A-Za-z0-9_-]+\z/, code, "expected urlsafe base64 characters only")
  end

  test "expired? returns true when varnishable_at is in the past" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    travel UserAuthorizationCode::CODE_TTL + 1.second do
      assert_predicate code, :expired?
    end
  end

  test "expired? returns false when varnishable_at is in the future" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    assert_not code.expired?
  end

  test "consumed? returns true when consumed_at is present" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    assert_not code.consumed?
    code.consume!

    assert_predicate code, :consumed?
  end

  test "revoked? returns true when revoked_at is present" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    assert_not code.revoked?
    code.revoke!

    assert_predicate code, :revoked?
  end

  test "usable? returns true when not expired, consumed, or revoked" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    assert_predicate code, :usable?
  end

  test "usable? returns false when consumed" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    code.consume!

    assert_not code.usable?
  end

  test "consume! raises when already consumed" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    code.consume!

    assert_raises(RuntimeError, "Authorization code already consumed") { code.consume! }
  end

  test "consume! raises when revoked" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    code.revoke!

    assert_raises(RuntimeError, "Authorization code revoked") { code.consume! }
  end

  test "consume! raises when expired" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    travel UserAuthorizationCode::CODE_TTL + 1.second do
      assert_raises(RuntimeError, "Authorization code expired") { code.consume! }
    end
  end

  test "revoke! is idempotent" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    code.revoke!
    revoked_at = code.revoked_at

    code.revoke!

    assert_equal revoked_at, code.revoked_at, "revoked_at should not change on second revoke"
  end

  test "verify_pkce returns true for correct verifier" do
    verifier = "test_code_verifier_abcdefghijklmnop"
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    assert code.verify_pkce(verifier)
  end

  test "verify_pkce returns false for incorrect verifier" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    assert_not code.verify_pkce("wrong_verifier_value")
  end

  test "verify_pkce returns false for blank verifier" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    assert_not code.verify_pkce("")
    assert_not code.verify_pkce(nil)
  end

  test "valid scope returns only usable codes" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    assert_includes UserAuthorizationCode.valid, code

    code.consume!

    assert_not_includes UserAuthorizationCode.valid, code
  end

  test "validates code presence" do
    code = UserAuthorizationCode.new(
      user: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
      varnishable_at: 10.seconds.from_now,
    )

    assert_not code.valid?
    assert_not_empty code.errors[:code]
  end

  test "validates client_id presence" do
    code = UserAuthorizationCode.new(
      code: UserAuthorizationCode.generate_code,
      user: @user,
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
      varnishable_at: 10.seconds.from_now,
    )

    assert_not code.valid?
    assert_not_empty code.errors[:client_id]
  end

  test "validates redirect_uri presence" do
    code = UserAuthorizationCode.new(
      code: UserAuthorizationCode.generate_code,
      user: @user,
      client_id: "test_client",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
      varnishable_at: 10.seconds.from_now,
    )

    assert_not code.valid?
    assert_not_empty code.errors[:redirect_uri]
  end

  test "validates code_challenge presence" do
    code = UserAuthorizationCode.new(
      code: UserAuthorizationCode.generate_code,
      user: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge_method: "S256",
      varnishable_at: 10.seconds.from_now,
    )

    assert_not code.valid?
    assert_not_empty code.errors[:code_challenge]
  end

  test "validates code_challenge_method inclusion" do
    code = UserAuthorizationCode.new(
      code: UserAuthorizationCode.generate_code,
      user: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "plain",
      varnishable_at: 10.seconds.from_now,
    )

    assert_not code.valid?
    assert_not_empty code.errors[:code_challenge_method]
  end

  test "validates varnishable_at presence" do
    code = UserAuthorizationCode.new(
      code: UserAuthorizationCode.generate_code,
      user: @user,
      client_id: "test_client",
      redirect_uri: "http://example.com/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    assert_not code.valid?
    assert_not_empty code.errors[:varnishable_at]
  end
end
