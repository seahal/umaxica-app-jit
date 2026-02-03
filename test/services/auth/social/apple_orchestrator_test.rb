# frozen_string_literal: true

require "test_helper"

class AppleOrchestratorTest < ActiveSupport::TestCase
  fixtures :users, :user_statuses, :user_social_apple_statuses

  def setup
    @user_one = users(:one)
    @user_two = users(:two)
    UserSocialApple.where(user: [@user_one, @user_two]).delete_all
  end

  test "current_user nil and existing uid signs in existing user" do
    existing = UserSocialApple.create!(
      user: @user_one,
      uid: "apple_uid_existing",
      provider: "apple",
      token: "token_old",
      expires_at: 1.week.from_now.to_i,
      user_social_apple_status: user_social_apple_statuses(:active),
    )

    auth = build_auth(uid: existing.uid, token: "token_new")

    result = Auth::Social::AppleOrchestrator.new(auth_hash: auth, current_user: nil).call

    assert_predicate result, :success?
    assert_equal :sign_in, result.action
    assert_equal @user_one.id, result.user.id
    assert_equal existing.id, result.identity.id
    assert_equal "token_new", result.identity.reload.token
  end

  test "current_user nil and new uid signs up" do
    auth = build_auth(uid: "apple_uid_new")

    assert_difference("User.count", 1) do
      assert_difference("UserSocialApple.count", 1) do
        result = Auth::Social::AppleOrchestrator.new(auth_hash: auth, current_user: nil).call

        assert_predicate result, :success?
        assert_equal :sign_up, result.action
        assert_predicate result.user, :persisted?
        assert_equal result.user.id, result.identity.user_id
      end
    end
  end

  test "current_user logged in and no identity links new uid" do
    auth = build_auth(uid: "apple_uid_link")

    result = Auth::Social::AppleOrchestrator.new(auth_hash: auth, current_user: @user_one).call

    assert_predicate result, :success?
    assert_equal :link, result.action
    assert_equal @user_one.id, result.identity.user_id
    assert_equal "apple_uid_link", result.identity.uid
  end

  test "current_user logged in and same uid updates identity" do
    identity = UserSocialApple.create!(
      user: @user_one,
      uid: "apple_uid_same",
      provider: "apple",
      token: "token_old",
      expires_at: 1.week.from_now.to_i,
      user_social_apple_status: user_social_apple_statuses(:revoked),
    )

    auth = build_auth(uid: "apple_uid_same", token: "token_new")

    result = Auth::Social::AppleOrchestrator.new(auth_hash: auth, current_user: @user_one).call

    assert_predicate result, :success?
    assert_equal :link, result.action

    identity.reload
    assert_equal "token_new", identity.token
    assert_not_nil identity.last_authenticated_at
    assert_equal UserSocialAppleStatus::ACTIVE, identity.user_identity_social_apple_status_id
  end

  test "current_user logged in and uid belongs to another user fails" do
    UserSocialApple.create!(
      user: @user_one,
      uid: "apple_uid_conflict",
      provider: "apple",
      token: "token_old",
      expires_at: 1.week.from_now.to_i,
      user_social_apple_status: user_social_apple_statuses(:active),
    )

    auth = build_auth(uid: "apple_uid_conflict")

    result = Auth::Social::AppleOrchestrator.new(auth_hash: auth, current_user: @user_two).call

    assert_not_predicate result, :success?
    assert_equal "errors.social_auth.linked_to_another_user", result.error_key
  end

  test "missing uid fails" do
    auth = build_auth(uid: nil)

    result = Auth::Social::AppleOrchestrator.new(auth_hash: auth, current_user: nil).call

    assert_not_predicate result, :success?
    assert_equal "errors.social_auth.missing_uid", result.error_key
  end

  test "email nil still succeeds" do
    auth = build_auth(uid: "apple_uid_no_email", email: nil)

    result = Auth::Social::AppleOrchestrator.new(auth_hash: auth, current_user: nil).call

    assert_predicate result, :success?
    assert_equal :sign_up, result.action
  end

  private

  def build_auth(uid:, token: "apple_token", email: "user@example.com")
    info = {}
    info[:email] = email if email.present?

    OmniAuth::AuthHash.new(
      provider: "apple",
      uid: uid,
      info: info,
      credentials: {
        token: token,
        expires_at: 1.week.from_now.to_i,
      },
    )
  end
end
