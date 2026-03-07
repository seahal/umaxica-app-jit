# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: users
# Database name: principal
#
#  id                    :bigint           not null, primary key
#  deactivated_at        :datetime
#  deletable_at          :datetime         default(Infinity), not null
#  last_reauth_at        :datetime
#  lock_version          :integer          default(0), not null
#  multi_factor_enabled  :boolean          default(FALSE), not null
#  purged_at             :datetime
#  scheduled_purge_at    :datetime
#  shreddable_at         :datetime         default(Infinity), not null
#  withdrawal_started_at :datetime
#  withdrawn_at          :datetime         default(Infinity)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  public_id             :string(255)      default(""), not null
#  status_id             :bigint           default(11), not null
#  visibility_id         :bigint           default(2), not null
#
# Indexes
#
#  index_users_on_deactivated_at         (deactivated_at) WHERE (deactivated_at IS NOT NULL)
#  index_users_on_deletable_at           (deletable_at)
#  index_users_on_public_id              (public_id) UNIQUE
#  index_users_on_purged_at              (purged_at) WHERE (purged_at IS NOT NULL)
#  index_users_on_scheduled_purge_at     (scheduled_purge_at) WHERE (scheduled_purge_at IS NOT NULL)
#  index_users_on_shreddable_at          (shreddable_at)
#  index_users_on_status_id              (status_id)
#  index_users_on_visibility_id          (visibility_id)
#  index_users_on_withdrawal_started_at  (withdrawal_started_at) WHERE (withdrawal_started_at IS NOT NULL)
#  index_users_on_withdrawn_at           (withdrawn_at) WHERE (withdrawn_at IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (status_id => user_statuses.id)
#  fk_rails_...  (visibility_id => user_visibilities.id)
#

require "test_helper"

class UserTest < ActiveSupport::TestCase
  NIL_UUID = "00000000-0000-0000-0000-000000000000"

  def setup
    [0, 1, 2, 3].each { |id| UserVisibility.find_or_create_by!(id: id) }

    @user =
      User.create!(public_id: "u_#{SecureRandom.hex(8)}") do |u|
        u.status_id = UserStatus::NOTHING
      end
  end

  test "should be valid" do
    assert_predicate @user, :valid?
  end

  test "should have timestamps" do
    assert_not_nil @user.created_at
    assert_not_nil @user.updated_at
  end

  test "should have one user_social_apple association" do
    assert_respond_to @user, :user_social_apple
    assert_equal :has_one, @user.class.reflect_on_association(:user_social_apple).macro
  end

  test "should have one user_social_google association" do
    assert_respond_to @user, :user_social_google
    assert_equal :has_one, @user.class.reflect_on_association(:user_social_google).macro
  end

  test "staff? should return false" do
    assert_not @user.staff?
  end

  test "user? should return true" do
    assert_predicate @user, :user?
  end

  test "should set default status before creation" do
    user = User.create!

    assert_equal UserStatus::NOTHING, user.status_id
  end

  test "should default visibility_id to staff (2)" do
    user = User.create!

    assert_equal UserVisibility::STAFF, user.visibility_id
  end

  test "visibility association resolves to UserVisibility with id 2 by default" do
    user = User.create!

    assert_equal UserVisibility::STAFF, user.visibility.id
  end

  test "invalid visibility_id is rejected by foreign key" do
    user = User.new(
      public_id: "u_fk_#{SecureRandom.hex(6)}",
      status_id: UserStatus::NOTHING,
      visibility_id: 9_999,
    )
    assert_raises(ActiveRecord::InvalidForeignKey) do
      user.save!(validate: false)
    end
  end

  test "should have many user_emails association" do
    assert_respond_to @user, :user_emails
    assert_equal :has_many, @user.class.reflect_on_association(:user_emails).macro
  end

  test "should have many user_secrets association" do
    assert_respond_to @user, :user_secrets
    assert_equal :has_many, @user.class.reflect_on_association(:user_secrets).macro
  end

  test "should have many user_passkeys association" do
    assert_respond_to @user, :user_passkeys
    assert_equal :has_many, @user.class.reflect_on_association(:user_passkeys).macro
  end

  test "boundary values: public_id must be unique" do
    @user.public_id = "duplicate-id"
    @user.save!

    duplicate_user = User.new(public_id: "duplicate-id")

    assert_not duplicate_user.valid?
    assert_not_empty duplicate_user.errors[:public_id]
  end

  test "boundary values: public_id length" do
    @user.public_id = "a" * 22

    assert_not @user.valid?
    assert_not_empty @user.errors[:public_id]
  end

  test "association deletion: destroys dependent user_emails" do
    email = UserEmail.create!(user: @user, address: "delete_test@example.com")
    assert_difference("UserEmail.count", -1) do
      @user.destroy
    end
    assert_raise(ActiveRecord::RecordNotFound) { email.reload }
  end

  test "association deletion: destroys dependent user_telephones" do
    phone = UserTelephone.create!(user: @user, number: "+15551234567")
    assert_difference("UserTelephone.count", -1) do
      @user.destroy
    end
    assert_raise(ActiveRecord::RecordNotFound) { phone.reload }
  end

  test "association deletion: destroys dependent user_tokens" do
    token = UserToken.create!(
      user: @user,
      refresh_expires_at: 1.day.from_now,
    )
    assert_difference("UserToken.count", -@user.user_tokens.count) do
      @user.destroy
    end
    assert_raise(ActiveRecord::RecordNotFound) { token.reload }
  end

  test "owned_avatars association" do
    capability = AvatarCapability.find_or_create_by!(id: AvatarCapability::NORMAL)
    handle = Handle.create!(
      handle: "owned_handle-#{SecureRandom.hex(4)}",
      cooldown_until: Time.current,
    )
    avatar = Avatar.create!(capability: capability, active_handle: handle, moniker: "Owned")
    avatar.avatar_assignments.create!(user: @user, role: "owner")

    assert_includes @user.owned_avatars, avatar
  end

  test "deletable scope picks users with past deletable_at" do
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", deletable_at: 1.hour.ago)

    assert_includes User.deletable, user
  end

  test "deletable scope excludes users with default deletable_at" do
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}")

    assert_not_includes User.deletable, user
  end

  test "deletable scope excludes users with future deletable_at" do
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", deletable_at: 1.hour.from_now)

    assert_not_includes User.deletable, user
  end

  test "shreddable scope excludes users with default shreddable_at" do
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}")

    assert_not_includes User.shreddable(Time.current), user
  end

  test "shreddable scope includes users with past shreddable_at" do
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", shreddable_at: 1.day.ago)

    assert_includes User.shreddable(Time.current), user
  end

  private

  def root_workspace
    Workspace.find_or_create_by!(id: NIL_UUID) do |workspace|
      workspace.name = "Root Workspace"
      workspace.domain = "root.example.com"
      workspace.parent_organization = NIL_UUID
    end
  end
end
