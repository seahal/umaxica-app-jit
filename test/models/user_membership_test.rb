# == Schema Information
#
# Table name: user_memberships
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  joined_at    :datetime         not null
#  left_at      :datetime         default("-infinity"), not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#  workspace_id :uuid             not null
#
# Indexes
#
#  index_user_memberships_on_user_id_and_workspace_id  (user_id,workspace_id) UNIQUE
#  index_user_memberships_on_workspace_id              (workspace_id)
#

require "test_helper"

class UserMembershipTest < ActiveSupport::TestCase
  NIL_UUID = "00000000-0000-0000-0000-000000000000"

  test "associates user and workspace" do
    user = users(:one)
    workspace = Workspace.create!(
      name: "Test Workspace",
      domain: "membership-workspace.example.com",
      parent_organization: root_workspace.id
    )

    membership = UserMembership.create!(user: user, workspace: workspace)

    assert_equal user, membership.user
    assert_equal workspace, membership.workspace
  end

  test "active scope filters by left_at" do
    user = users(:one)
    active_workspace = Workspace.create!(
      name: "Active Workspace",
      domain: "active-workspace.example.com",
      parent_organization: root_workspace.id
    )
    inactive_workspace = Workspace.create!(
      name: "Inactive Workspace",
      domain: "inactive-workspace.example.com",
      parent_organization: root_workspace.id
    )

    active_membership = UserMembership.create!(user: user, workspace: active_workspace, left_at: Float::INFINITY)
    inactive_membership = UserMembership.create!(user: user, workspace: inactive_workspace, left_at: Time.current)

    assert_includes UserMembership.active, active_membership
    assert_not_includes UserMembership.active, inactive_membership
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
