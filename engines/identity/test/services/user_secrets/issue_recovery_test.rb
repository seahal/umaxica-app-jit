# typed: false
# frozen_string_literal: true

require "test_helper"

class UserSecrets::IssueRecoveryTest < ActiveSupport::TestCase
  fixtures :user_statuses, :user_secret_kinds, :user_secret_statuses

  setup do
    @user = User.create!(
      status_id: UserStatus::NOTHING,
      public_id: "rec_#{SecureRandom.hex(4)}",
    )
    @user.user_emails.create!(
      address: "rec-#{@user.public_id}@example.com",
      user_email_status_id: UserEmailStatus::VERIFIED,
    )
    @actor = @user
  end

  test "issues a new recovery secret" do
    result = UserSecrets::IssueRecovery.call(actor: @actor, user: @user)

    assert_predicate result.secret, :persisted?
    assert_predicate result.raw_secret, :present?
    assert_equal result.raw_secret.first(4), result.secret.name
  end

  test "returns raw_secret that can be verified against the secret" do
    result = UserSecrets::IssueRecovery.call(actor: @actor, user: @user)

    assert result.secret.authenticate(result.raw_secret)
  end

  test "revokes existing recovery secrets before issuing new one" do
    UserSecrets::IssueRecovery.call(actor: @actor, user: @user)

    assert_equal 1, @user.user_secrets.where(user_secret_kind_id: UserSecretKind::RECOVERY).count

    UserSecrets::IssueRecovery.call(actor: @actor, user: @user)

    recovery_secrets = @user.user_secrets.where(user_secret_kind_id: UserSecretKind::RECOVERY).order(:created_at)

    assert_equal 2, recovery_secrets.count
    assert_equal UserSecretStatus::REVOKED, recovery_secrets.first.user_secret_status_id
    assert_equal UserSecretStatus::ACTIVE, recovery_secrets.last.user_secret_status_id
  end

  test "creates audit record for the action" do
    assert_difference -> { UserActivity.where(event_id: UserActivityEvent::RECOVERY_CODES_GENERATED).count }, 1 do
      UserSecrets::IssueRecovery.call(actor: @actor, user: @user)
    end
  end
end
