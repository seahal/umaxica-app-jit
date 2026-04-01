# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: authorization_codes
# Database name: token
#
#  id                    :bigint           not null, primary key
#  code                  :string(64)       not null
#  code_challenge        :string           not null
#  code_challenge_method :string(8)        default("S256"), not null
#  consumed_at           :datetime
#  expires_at            :datetime         not null
#  nonce                 :string
#  redirect_uri          :text             not null
#  revoked_at            :datetime
#  scope                 :string
#  state                 :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  client_id             :string(64)       not null
#  staff_id              :bigint
#  user_id               :bigint
#
# Indexes
#
#  index_authorization_codes_on_code        (code) UNIQUE
#  index_authorization_codes_on_expires_at  (expires_at)
#  index_authorization_codes_on_staff_id    (staff_id)
#  index_authorization_codes_on_user_id     (user_id)
#
require "test_helper"

class AuthorizationCodeTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @code_challenge = Base64.urlsafe_encode64(
      Digest::SHA256.digest("test_code_verifier_abcdefghijklmnop"),
      padding: false,
    )
  end

  test "issue! creates a valid authorization code" do
    code = AuthorizationCode.issue!(
      user: @user,
      client_id: "core_app",
      redirect_uri: "http://www.app.localhost:3000/auth/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
      state: "test_state",
    )

    assert_predicate code, :persisted?
    assert_equal @user.id, code.user_id
    assert_equal "core_app", code.client_id
    assert_equal "S256", code.code_challenge_method
    assert_equal @code_challenge, code.code_challenge
    assert_equal "test_state", code.state
    assert_operator code.code.length, :>=, 32
    assert_predicate code, :usable?
  end

  test "generate_code returns unique codes" do
    codes = 10.times.map { AuthorizationCode.generate_code }

    assert_equal 10, codes.uniq.size
  end

  test "expired? returns true after TTL" do
    code = AuthorizationCode.issue!(
      user: @user,
      client_id: "core_app",
      redirect_uri: "http://www.app.localhost:3000/auth/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    assert_not code.expired?

    travel AuthorizationCode::CODE_TTL + 1.second do
      assert_predicate code, :expired?
      assert_not code.usable?
    end
  end

  test "consume! marks code as consumed" do
    code = AuthorizationCode.issue!(
      user: @user,
      client_id: "core_app",
      redirect_uri: "http://www.app.localhost:3000/auth/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    assert_not code.consumed?
    code.consume!

    assert_predicate code, :consumed?
    assert_not code.usable?
  end

  test "consume! raises if already consumed" do
    code = AuthorizationCode.issue!(
      user: @user,
      client_id: "core_app",
      redirect_uri: "http://www.app.localhost:3000/auth/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    code.consume!
    assert_raises(RuntimeError, "Authorization code already consumed") { code.consume! }
  end

  test "revoke! marks code as revoked" do
    code = AuthorizationCode.issue!(
      user: @user,
      client_id: "core_app",
      redirect_uri: "http://www.app.localhost:3000/auth/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    code.revoke!

    assert_predicate code, :revoked?
    assert_not code.usable?
  end

  test "verify_pkce returns true for correct verifier" do
    verifier = "test_code_verifier_abcdefghijklmnop"
    code = AuthorizationCode.issue!(
      user: @user,
      client_id: "core_app",
      redirect_uri: "http://www.app.localhost:3000/auth/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    assert code.verify_pkce(verifier)
  end

  test "verify_pkce returns false for wrong verifier" do
    code = AuthorizationCode.issue!(
      user: @user,
      client_id: "core_app",
      redirect_uri: "http://www.app.localhost:3000/auth/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    assert_not code.verify_pkce("wrong_verifier")
  end

  test "verify_pkce returns false for blank verifier" do
    code = AuthorizationCode.issue!(
      user: @user,
      client_id: "core_app",
      redirect_uri: "http://www.app.localhost:3000/auth/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    assert_not code.verify_pkce("")
    assert_not code.verify_pkce(nil)
  end

  test "valid scope returns only usable codes" do
    code = AuthorizationCode.issue!(
      user: @user,
      client_id: "core_app",
      redirect_uri: "http://www.app.localhost:3000/auth/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
    )

    assert_includes AuthorizationCode.valid, code

    code.consume!

    assert_not_includes AuthorizationCode.valid, code
  end

  test "validates code_challenge_method must be S256" do
    code = AuthorizationCode.new(
      code: AuthorizationCode.generate_code,
      user: @user,
      client_id: "core_app",
      redirect_uri: "http://www.app.localhost:3000/auth/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "plain",
      expires_at: 10.seconds.from_now,
    )

    assert_not code.valid?
    assert_predicate code.errors[:code_challenge_method], :any?, "code_challenge_method should have validation errors"
  end

  test "code uniqueness is enforced" do
    code_value = AuthorizationCode.generate_code

    AuthorizationCode.create!(
      code: code_value,
      user: @user,
      client_id: "core_app",
      redirect_uri: "http://www.app.localhost:3000/auth/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
      expires_at: 10.seconds.from_now,
    )

    duplicate = AuthorizationCode.new(
      code: code_value,
      user: @user,
      client_id: "docs_app",
      redirect_uri: "http://docs.app.localhost:3000/auth/callback",
      code_challenge: @code_challenge,
      code_challenge_method: "S256",
      expires_at: 10.seconds.from_now,
    )

    assert_not duplicate.valid?
    assert_predicate duplicate.errors[:code], :any?, "code should have uniqueness validation errors"
  end
end
