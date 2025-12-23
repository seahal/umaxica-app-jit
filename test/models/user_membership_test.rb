require "test_helper"

class UserMembershipTest < ActiveSupport::TestCase
  test "associates user and workspace" do
    user = users(:one)
    workspace = Workspace.create!(name: "Test Workspace")

    membership = UserMembership.create!(user: user, workspace: workspace)

    assert_equal user, membership.user
    assert_equal workspace, membership.workspace
  end

  test "active scope filters by left_at" do
    user = users(:one)
    active_workspace = Workspace.create!(name: "Active Workspace")
    inactive_workspace = Workspace.create!(name: "Inactive Workspace")

    active_membership = UserMembership.create!(user: user, workspace: active_workspace, left_at: nil)
    inactive_membership = UserMembership.create!(user: user, workspace: inactive_workspace, left_at: Time.current)

    assert_includes UserMembership.active, active_membership
    assert_not_includes UserMembership.active, inactive_membership
  end
end
