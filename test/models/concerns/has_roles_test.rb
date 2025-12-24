require "test_helper"

class HasRolesTest < ActiveSupport::TestCase
  NIL_UUID = "00000000-0000-0000-0000-000000000000"

  setup do
    @organization = Workspace.create!(
      name: "Test Org",
      domain: "test.com",
      parent_organization: root_workspace.id
    )
    @admin_role = Role.create!(key: "admin", name: "Admin", organization: @organization)
    @manager_role = Role.create!(key: "manager", name: "Manager", organization: @organization)
    @editor_role = Role.create!(key: "editor", name: "Editor", organization: @organization)
    @viewer_role = Role.create!(key: "viewer", name: "Viewer", organization: @organization)
    # Use an existing user from fixtures or create with proper attributes
    @user = users(:one) # Using fixture
  end

  test "has_role? returns true when user has the role" do
    RoleAssignment.create!(user: @user, role: @admin_role)

    assert @user.has_role?("admin", organization: @organization)
  end

  test "has_role? returns false when user does not have the role" do
    assert_not @user.has_role?("admin", organization: @organization)
  end

  test "has_any_role? returns true when user has any of the specified roles" do
    RoleAssignment.create!(user: @user, role: @editor_role)

    assert @user.has_any_role?("admin", "editor", organization: @organization)
  end

  test "admin_or_manager? returns true for admin role" do
    RoleAssignment.create!(user: @user, role: @admin_role)

    assert @user.admin_or_manager?(organization: @organization)
  end

  test "can_edit? returns true for editor role" do
    RoleAssignment.create!(user: @user, role: @editor_role)

    assert @user.can_edit?(organization: @organization)
  end

  test "can_view? returns true for viewer role" do
    RoleAssignment.create!(user: @user, role: @viewer_role)

    assert @user.can_view?(organization: @organization)
  end

  test "can_contribute? returns true for manager role" do
    RoleAssignment.create!(user: @user, role: @manager_role)

    assert @user.can_contribute?(organization: @organization)
  end

  test "roles_in returns roles for specific organization" do
    RoleAssignment.create!(user: @user, role: @admin_role)

    roles = @user.roles_in(@organization)

    assert_includes roles, @admin_role
    assert_equal 1, roles.count
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
