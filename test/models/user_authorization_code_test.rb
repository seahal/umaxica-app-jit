# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_authorization_codes
# Database name: principal
#
#  id                    :bigint           not null, primary key
#  acr                   :string           default("aal1"), not null
#  auth_method           :string           default(""), not null
#  code                  :string(64)       not null
#  code_challenge        :string           not null
#  code_challenge_method :string(8)        default("S256"), not null
#  consumed_at           :datetime
#  nonce                 :string
#  redirect_uri          :text             not null
#  revoked_at            :datetime
#  scope                 :string
#  state                 :string
#  varnishable_at        :datetime         not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  client_id             :string(64)       not null
#  user_id               :bigint           not null
#
# Indexes
#
#  index_user_authorization_codes_on_code            (code) UNIQUE
#  index_user_authorization_codes_on_user_id         (user_id)
#  index_user_authorization_codes_on_varnishable_at  (varnishable_at)
#
require "test_helper"

class UserAuthorizationCodeTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: UserStatus::NOTHING)
    @code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "https://example.com/callback",
      code_challenge: "test_challenge",
      code_challenge_method: "S256",
    )
  end

  test "inherits from PrincipalRecord" do
    assert_operator UserAuthorizationCode, :<, PrincipalRecord
  end

  test "belongs to user" do
    association = UserAuthorizationCode.reflect_on_association(:user)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "includes OidcAuthorizationCode concern" do
    assert_includes UserAuthorizationCode.ancestors, OidcAuthorizationCode
  end

  test "subject_association_name returns :user" do
    assert_equal :user, UserAuthorizationCode.subject_association_name
  end

  test "can be created with issue!" do
    assert_not_nil @code
    assert_equal @user.id, @code.user_id
    assert_equal "test_client", @code.client_id
  end

  test "code is generated automatically" do
    assert_not_nil @code.code
    assert_predicate @code.code, :present?
  end

  test "code is unique" do
    duplicate = UserAuthorizationCode.new(
      user: @user,
      code: @code.code,
      client_id: "another_client",
      redirect_uri: "https://example.com/callback",
      code_challenge: "another_challenge",
      varnishable_at: 10.seconds.from_now,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:code]
  end

  test "validates code presence" do
    code = UserAuthorizationCode.new(
      user: @user,
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
      varnishable_at: 10.seconds.from_now,
    )
    code.code = nil

    assert_not code.valid?
    assert_not_empty code.errors[:code]
  end

  test "validates client_id presence" do
    code = UserAuthorizationCode.new(
      user: @user,
      code: "valid_code",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
      varnishable_at: 10.seconds.from_now,
    )
    code.client_id = nil

    assert_not code.valid?
    assert_not_empty code.errors[:client_id]
  end

  test "validates redirect_uri presence" do
    code = UserAuthorizationCode.new(
      user: @user,
      code: "valid_code",
      client_id: "test",
      code_challenge: "challenge",
      varnishable_at: 10.seconds.from_now,
    )
    code.redirect_uri = nil

    assert_not code.valid?
    assert_not_empty code.errors[:redirect_uri]
  end

  test "validates code_challenge presence" do
    code = UserAuthorizationCode.new(
      user: @user,
      code: "valid_code",
      client_id: "test",
      redirect_uri: "https://example.com",
      varnishable_at: 10.seconds.from_now,
    )
    code.code_challenge = nil

    assert_not code.valid?
    assert_not_empty code.errors[:code_challenge]
  end

  test "validates code_challenge_method inclusion" do
    code = UserAuthorizationCode.new(
      user: @user,
      code: "valid_code",
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
      code_challenge_method: "invalid",
      varnishable_at: 10.seconds.from_now,
    )

    assert_not code.valid?
    assert_not_empty code.errors[:code_challenge_method]
  end

  test "validates varnishable_at presence" do
    code = UserAuthorizationCode.new(
      user: @user,
      code: "valid_code",
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
    )
    code.varnishable_at = nil

    assert_not code.valid?
    assert_not_empty code.errors[:varnishable_at]
  end

  test "default acr is aal1" do
    assert_equal "aal1", @code.acr
  end

  test "default auth_method is empty string" do
    assert_equal "", @code.auth_method
  end

  test "expired? returns true when varnishable_at is in the past" do
    @code.update!(varnishable_at: 1.second.ago)

    assert_predicate @code, :expired?
  end

  test "expired? returns false when varnishable_at is in the future" do
    @code.update!(varnishable_at: 10.seconds.from_now)

    assert_not @code.expired?
  end

  test "consumed? returns true when consumed_at is set" do
    @code.update!(consumed_at: Time.current)

    assert_predicate @code, :consumed?
  end

  test "consumed? returns false when consumed_at is nil" do
    assert_not @code.consumed?
  end

  test "revoked? returns true when revoked_at is set" do
    @code.update!(revoked_at: Time.current)

    assert_predicate @code, :revoked?
  end

  test "revoked? returns false when revoked_at is nil" do
    assert_not @code.revoked?
  end

  test "usable? returns true when not expired, consumed, or revoked" do
    @code.update!(varnishable_at: 10.seconds.from_now, consumed_at: nil, revoked_at: nil)

    assert_predicate @code, :usable?
  end

  test "usable? returns false when expired" do
    @code.update!(varnishable_at: 1.second.ago)

    assert_not @code.usable?
  end

  test "usable? returns false when consumed" do
    @code.update!(consumed_at: Time.current)

    assert_not @code.usable?
  end

  test "usable? returns false when revoked" do
    @code.update!(revoked_at: Time.current)

    assert_not @code.usable?
  end

  test "consume! sets consumed_at" do
    @code.consume!

    assert_predicate @code.consumed_at, :present?
  end

  test "consume! raises when already consumed" do
    @code.consume!

    assert_raises(RuntimeError, "Authorization code already consumed") do
      @code.consume!
    end
  end

  test "consume! raises when revoked" do
    @code.revoke!

    assert_raises(RuntimeError, "Authorization code revoked") do
      @code.consume!
    end
  end

  test "consume! raises when expired" do
    @code.update!(varnishable_at: 1.second.ago)

    assert_raises(RuntimeError, "Authorization code expired") do
      @code.consume!
    end
  end

  test "revoke! sets revoked_at" do
    @code.revoke!

    assert_predicate @code.revoked_at, :present?
  end

  test "revoke! is idempotent" do
    @code.revoke!
    original_revoked_at = @code.revoked_at
    sleep(0.01)
    @code.revoke!

    assert_equal original_revoked_at, @code.revoked_at
  end

  test "verify_pkce returns true for valid verifier" do
    code_verifier = "test_verifier"
    expected_challenge = Base64.urlsafe_encode64(
      Digest::SHA256.digest(code_verifier),
      padding: false,
    )
    @code.update!(code_challenge: expected_challenge)

    assert @code.verify_pkce(code_verifier)
  end

  test "verify_pkce returns false for invalid verifier" do
    @code.update!(code_challenge: "valid_challenge")

    assert_not @code.verify_pkce("wrong_verifier")
  end

  test "verify_pkce returns false when code_verifier is blank" do
    assert_not @code.verify_pkce(nil)
    assert_not @code.verify_pkce("")
  end

  test "subject returns the associated user" do
    assert_equal @user, @code.subject
  end

  test "subject_id returns the user_id" do
    assert_equal @user.id, @code.subject_id
  end

  test "valid scope returns non-expired, non-consumed, non-revoked codes" do
    expired = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
    )
    expired.update!(varnishable_at: 1.second.ago)

    consumed = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
    )
    consumed.consume!

    revoked = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
    )
    revoked.revoke!

    valid_codes = UserAuthorizationCode.valid.pluck(:id)

    assert_includes valid_codes, @code.id
    assert_not_includes valid_codes, expired.id
    assert_not_includes valid_codes, consumed.id
    assert_not_includes valid_codes, revoked.id
  end

  test "user association loads user correctly" do
    assert_equal @user, @code.user
    assert_equal @user.id, @code.user.id
  end

  test "timestamps are set on creation" do
    assert_not_nil @code.created_at
    assert_not_nil @code.updated_at
    assert_operator @code.created_at, :<=, @code.updated_at
  end

  test "association deletion: destroys when user is destroyed" do
    @code.reload
    @user.destroy

    assert_raise(ActiveRecord::RecordNotFound) { @code.reload }
  end

  test "issue! accepts optional parameters" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test_client",
      redirect_uri: "https://example.com/callback",
      code_challenge: "challenge",
      code_challenge_method: "S256",
      scope: "openid profile",
      state: "random_state",
      nonce: "random_nonce",
      auth_method: ["password"],
      acr: "aal2",
    )

    assert_equal "openid profile", code.scope
    assert_equal "random_state", code.state
    assert_equal "random_nonce", code.nonce
    assert_equal '["password"]', code.auth_method
    assert_equal "aal2", code.acr
  end

  test "issue! serializes auth_method as JSON when array" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
      auth_method: [:password, :mfa],
    )

    assert_equal '["password","mfa"]', code.auth_method
  end

  test "issue! stores empty string when auth_method is nil" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
      auth_method: nil,
    )

    assert_equal "", code.auth_method
  end

  test "issue! defaults acr to aal1 when not provided" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
    )

    assert_equal "aal1", code.acr
  end

  test "code has maximum length of 64" do
    code = UserAuthorizationCode.new(
      user: @user,
      code: "a" * 65,
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
      varnishable_at: 10.seconds.from_now,
    )

    assert_not code.valid?
    assert_not_empty code.errors[:code]
  end

  test "client_id has maximum length of 64" do
    code = UserAuthorizationCode.new(
      user: @user,
      code: "valid_code",
      client_id: "a" * 65,
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
      varnishable_at: 10.seconds.from_now,
    )

    assert_not code.valid?
    assert_not_empty code.errors[:client_id]
  end

  test "code_challenge_method has maximum length of 8" do
    code = UserAuthorizationCode.new(
      user: @user,
      code: "valid_code",
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
      code_challenge_method: "a" * 9,
      varnishable_at: 10.seconds.from_now,
    )

    assert_not code.valid?
    assert_not_empty code.errors[:code_challenge_method]
  end

  test "index on varnishable_at exists" do
    indexes = UserAuthorizationCode.connection.indexes("user_authorization_codes")
    varnishable_index = indexes.find { |i| i.columns.include?("varnishable_at") }

    assert_not_nil varnishable_index, "Expected index on varnishable_at to exist"
  end

  test "index on user_id exists" do
    indexes = UserAuthorizationCode.connection.indexes("user_authorization_codes")
    user_id_index = indexes.find { |i| i.columns.include?("user_id") }

    assert_not_nil user_id_index, "Expected index on user_id to exist"
  end

  test "unique index on code exists" do
    indexes = UserAuthorizationCode.connection.indexes("user_authorization_codes")
    code_index = indexes.find { |i| i.columns == ["code"] && i.unique }

    assert_not_nil code_index, "Expected unique index on code to exist"
  end

  test "issue! defaults code_challenge_method to S256" do
    code = UserAuthorizationCode.issue!(
      subject: @user,
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
    )

    assert_equal "S256", code.code_challenge_method
  end
end
