# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                      :uuid             not null, primary key
#  webauthn_id             :string           default(""), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  public_id               :string(255)      default("")
#  user_identity_status_id :string(255)      default("NEYO"), not null
#  withdrawn_at            :datetime         default("infinity")
#
# Indexes
#
#  index_users_on_public_id                (public_id) UNIQUE
#  index_users_on_user_identity_status_id  (user_identity_status_id)
#  index_users_on_withdrawn_at             (withdrawn_at)
#

require "test_helper"

class UserTest < ActiveSupport::TestCase
  NIL_UUID = "00000000-0000-0000-0000-000000000000"

  def setup
    @user = users(:one)
  end

  test "should be valid" do
    assert_predicate @user, :valid?
  end

  test "should have timestamps" do
    assert_not_nil @user.created_at
    assert_not_nil @user.updated_at
  end

  test "should have one user_identity_social_apple association" do
    assert_respond_to @user, :user_identity_social_apple
    assert_equal :has_one, @user.class.reflect_on_association(:user_identity_social_apple).macro
  end

  test "should have one user_identity_social_google association" do
    assert_respond_to @user, :user_identity_social_google
    assert_equal :has_one, @user.class.reflect_on_association(:user_identity_social_google).macro
  end

  test "staff? should return false" do
    assert_not @user.staff?
  end

  test "user? should return true" do
    assert_predicate @user, :user?
  end

  test "should set default status before creation" do
    user = User.create!

    assert_equal UserIdentityStatus::NEYO, user.user_identity_status_id
  end

  test "should have many user_identity_emails association" do
    assert_respond_to @user, :user_identity_emails
    assert_equal :has_many, @user.class.reflect_on_association(:user_identity_emails).macro
  end

  test "should have many user_identity_secrets association" do
    assert_respond_to @user, :user_identity_secrets
    assert_equal :has_many, @user.class.reflect_on_association(:user_identity_secrets).macro
  end

  test "should have many user_identity_passkeys association" do
    assert_respond_to @user, :user_identity_passkeys
    assert_equal :has_many, @user.class.reflect_on_association(:user_identity_passkeys).macro
  end

  test "has_role? should correctly identify assigned roles" do
    workspace = Workspace.create!(
      name: "Test Workspace",
      domain: "test-workspace.example.com",
      parent_organization: root_workspace.id,
    )
    editor_role = Role.create!(key: "editor", name: "Editor", organization: workspace)
    Role.create!(key: "viewer", name: "Viewer", organization: workspace)

    # Assign editor role to the user
    RoleAssignment.create!(user: @user, role: editor_role)

    assert @user.has_role?("editor")
    assert_not @user.has_role?("viewer")
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

  test "association deletion: destroys dependent user_identity_emails" do
    email = UserIdentityEmail.create!(user: @user, address: "delete_test@example.com")
    assert_difference("UserIdentityEmail.count", -1) do
      @user.destroy
    end
    assert_raise(ActiveRecord::RecordNotFound) { email.reload }
  end

  test "association deletion: destroys dependent user_identity_telephones" do
    phone = UserIdentityTelephone.create!(user: @user, number: "+15551234567")
    assert_difference("UserIdentityTelephone.count", -1) do
      @user.destroy
    end
    assert_raise(ActiveRecord::RecordNotFound) { phone.reload }
  end

  test "association deletion: destroys dependent user_tokens" do
    token = UserToken.create!(
      user: @user,
      refresh_expires_at: 1.day.from_now,
    )
    assert_difference("UserToken.count", -1) do
      @user.destroy
    end
    assert_raise(ActiveRecord::RecordNotFound) { token.reload }
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
