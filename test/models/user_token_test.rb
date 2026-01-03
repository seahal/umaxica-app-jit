# frozen_string_literal: true

# == Schema Information
#
# Table name: user_tokens
#
#  id                   :uuid             not null, primary key
#  user_id              :uuid             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_token_status_id :string           default("NEYO"), not null
#  refresh_token_digest :binary
#  public_id            :string(21)       default(""), not null
#  refresh_expires_at   :datetime         not null
#  revoked_at           :datetime
#  rotated_at           :datetime
#  last_used_at         :datetime
#
# Indexes
#
#  index_user_tokens_on_public_id             (public_id) UNIQUE
#  index_user_tokens_on_refresh_expires_at    (refresh_expires_at)
#  index_user_tokens_on_refresh_token_digest  (refresh_token_digest) UNIQUE
#  index_user_tokens_on_revoked_at            (revoked_at)
#  index_user_tokens_on_user_id               (user_id)
#  index_user_tokens_on_user_token_status_id  (user_token_status_id)
#

require "test_helper"

# Covers refresh token behavior and session constraints for users.
class UserTokenTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: "NEYO")
    @token = UserToken.create!(user: @user)
  end

  test "inherits from TokensRecord" do
    assert_operator UserToken, :<, TokensRecord
  end

  test "belongs to user" do
    association = UserToken.reflect_on_association(:user)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "can be created with user" do
    assert_not_nil @token
    assert_equal @user.id, @token.user_id
  end

  test "generates UUID id automatically" do
    assert_not_nil @token.id
    assert_equal 36, @token.id.length
    assert_match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/, @token.id)
  end

  test "has created_at timestamp" do
    assert_not_nil @token.created_at
    assert_kind_of Time, @token.created_at
  end

  test "has updated_at timestamp" do
    assert_not_nil @token.updated_at
    assert_kind_of Time, @token.updated_at
  end

  test "user association loads user correctly" do
    assert_equal @user, @token.user
    assert_equal @user.id, @token.user.id
  end

  test "can load one fixture" do
    token_one = UserToken.find_by!(public_id: "one_user_token_000001")

    assert_not_nil token_one
    assert_not_nil token_one.user_id
  end

  test "can load two fixture" do
    token_two = UserToken.find_by!(public_id: "two_user_token_000001")

    assert_not_nil token_two
    assert_not_nil token_two.user_id
  end

  test "timestamp is set on creation" do
    user = User.create!
    token = UserToken.create!(user: user)

    assert_not_nil token.created_at
    assert_not_nil token.updated_at
    assert_operator token.created_at, :<=, token.updated_at
  end

  test "timestamp updates on save" do
    original_updated_at = @token.updated_at
    sleep(0.1)
    @token.update!(updated_at: Time.current)

    assert_operator @token.updated_at, :>, original_updated_at
  end

  test "enforces maximum concurrent sessions per user" do
    user = User.create!

    UserToken::MAX_SESSIONS_PER_USER.times do
      UserToken.create!(user: user)
    end

    extra_token = UserToken.new(user: user)

    assert_not extra_token.valid?
    assert_includes extra_token.errors[:base],
                    "exceeds maximum concurrent sessions per user (#{UserToken::MAX_SESSIONS_PER_USER})"
  end

  test "refresh token digest updates and authenticates" do
    @token.destroy
    token = UserToken.create!(user: @user)

    token.refresh_token = "verifier-value"
    token.save!

    assert_predicate token.refresh_token_digest, :present?
    assert token.authenticate_refresh_token("verifier-value")
    assert_not token.authenticate_refresh_token("wrong-value")
  end

  test "active state reflects revoked and expired refresh tokens" do
    token = UserToken.create!(user: User.create!)

    assert_predicate token, :active?

    token.update!(revoked_at: Time.current)
    assert_predicate token, :revoked?
    assert_not token.active?

    token.update!(revoked_at: nil, refresh_expires_at: 1.day.ago)
    assert_predicate token, :expired_refresh?
    assert_not token.active?
  end

  test "rotate_refresh_token! updates digest and timestamps" do
    @token.destroy
    token = UserToken.create!(user: @user)
    old_digest = token.refresh_token_digest

    new_token = token.rotate_refresh_token!

    assert_match(/\A#{token.public_id}\./, new_token)
    assert_not_equal old_digest, token.refresh_token_digest
    assert_predicate token.rotated_at, :present?
    assert_predicate token.last_used_at, :present?
  end

  test "rotate_refresh_token! generates token that authenticates" do
    @token.destroy
    token = UserToken.create!(user: @user)
    raw = token.rotate_refresh_token!

    public_id, verifier = UserToken.parse_refresh_token(raw)

    assert_equal token.public_id, public_id
    assert token.authenticate_refresh_token(verifier)
    assert_not token.authenticate_refresh_token("wrong-value")
  end

  test "parse_refresh_token splits public_id and verifier" do
    @token.destroy
    token = UserToken.create!(user: @user)
    raw = token.rotate_refresh_token!

    public_id, verifier = UserToken.parse_refresh_token(raw)

    assert_equal token.public_id, public_id
    assert_predicate verifier, :present?
  end

  test "public_id is generated and unique" do
    user = User.create!
    token1 = UserToken.create!(user: user)
    token2 = UserToken.create!(user: user)
    assert_not_equal token1.public_id, token2.public_id
  end

  test "public_id length boundary" do
    @token.public_id = "a" * 22
    assert_not @token.valid?
    assert_not_empty @token.errors[:public_id]
  end

  test "refresh_expires_at is required" do
    @token.refresh_expires_at = nil
    assert_not @token.valid?
    assert_not_empty @token.errors[:refresh_expires_at]
  end

  test "association deletion: destroys when user is destroyed" do
    @token.reload # Ensure it exists
    @user.destroy
    assert_raise(ActiveRecord::RecordNotFound) { @token.reload }
  end
end
