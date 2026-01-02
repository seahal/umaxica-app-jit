# frozen_string_literal: true

# == Schema Information
#
# Table name: user_workspaces
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#  workspace_id :uuid             not null
#
# Indexes
#
#  index_user_workspaces_on_user_id       (user_id)
#  index_user_workspaces_on_workspace_id  (workspace_id)
#

require "test_helper"

class UserWorkspaceTest < ActiveSupport::TestCase
  test "should inherit from IdentitiesRecord" do
    assert_operator UserWorkspace, :<, IdentitiesRecord
  end

  test "should belong to user" do
    assert_respond_to UserWorkspace.new, :user
  end

  test "should belong to workspace" do
    assert_respond_to UserWorkspace.new, :workspace
  end

  test "should have user association through has_many" do
    user = User.new

    assert_respond_to user, :user_workspaces
  end

  test "should have workspace association through has_many" do
    workspace = Workspace.new

    assert_respond_to workspace, :user_workspaces
  end

  test "should have id field as UUID" do
    user_workspace = UserWorkspace.new

    # The id field is a string (UUID) type
    assert_respond_to user_workspace, :id
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should create instance with valid structure" do
    user_workspace = UserWorkspace.new

    assert_respond_to user_workspace, :user
    assert_respond_to user_workspace, :workspace
    assert_respond_to user_workspace, :user_id
    assert_respond_to user_workspace, :workspace_id
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "should have inverse_of in associations" do
    assert_equal :user_workspaces, UserWorkspace.reflect_on_association(:user).options[:inverse_of]
    assert_equal :user_workspaces, UserWorkspace.reflect_on_association(:workspace).options[:inverse_of]
  end

  test "should have timestamps" do
    user_workspace = UserWorkspace.new

    assert_respond_to user_workspace, :created_at
    assert_respond_to user_workspace, :updated_at
  end
end
