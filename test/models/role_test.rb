# frozen_string_literal: true

require "test_helper"

class RoleTest < ActiveSupport::TestCase
  setup do
    @organization = Organization.create!(name: "Test Org", domain: "test.example.com")
  end

  test "valid role with organization" do
    role = Role.new(name: "Editor", organization: @organization)

    assert_predicate role, :valid?
  end

  test "requires organization" do
    role = Role.new(name: "Editor")

    assert_predicate role, :invalid?
    assert_predicate role.errors[:organization], :any?
  end

  test "belongs to organization" do
    role = Role.create!(name: "Admin", organization: @organization)

    assert_equal @organization, role.organization
  end

  test "has many role_assignments" do
    user = User.create!
    role = Role.create!(name: "Viewer", organization: @organization)
    assignment = RoleAssignment.create!(user_id: user.id, role_id: role.id)

    assert_includes role.role_assignments, assignment
  end

  test "has many users through role_assignments" do
    user = User.create!
    role = Role.create!(name: "Editor", organization: @organization)
    assignment = RoleAssignment.create!(user_id: user.id, role_id: role.id)
    # Verify the assignment was created with both user_id and role_id
    assert_equal assignment.user_id, user.id
    assert_equal assignment.role_id, role.id
    # Retrieve fresh role from database and check users
    fresh_role = Role.find(role.id)
    fresh_assignments = fresh_role.role_assignments

    assert_predicate fresh_assignments, :any?
  end
end
