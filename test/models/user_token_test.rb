require "test_helper"

class UserTokenTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
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
    token_one = user_tokens(:one)

    assert_not_nil token_one
    assert_not_nil token_one.user_id
  end

  test "can load two fixture" do
    token_two = user_tokens(:two)

    assert_not_nil token_two
    assert_not_nil token_two.user_id
  end

  test "timestamp is set on creation" do
    token = UserToken.create!(user: @user)

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
    user = @user
    existing_sessions = UserToken.where(user: user).count
    (UserToken::MAX_SESSIONS_PER_USER - existing_sessions).times do
      UserToken.create!(user: user)
    end

    extra_token = UserToken.new(user: user)

    assert_not extra_token.valid?
    assert_includes extra_token.errors[:base], "exceeds maximum concurrent sessions per user (#{UserToken::MAX_SESSIONS_PER_USER})"
  end
end
