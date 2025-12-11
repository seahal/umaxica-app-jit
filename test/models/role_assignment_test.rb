# frozen_string_literal: true

require "test_helper"

class RoleAssignmentTest < ActiveSupport::TestCase
  setup do
    @organization = Organization.create!(name: "Test Org", domain: "test.example.com")
    @user = User.create!
    @role = Role.create!(name: "Admin", organization: @organization)
  end

  test "valid role assignment for user" do
    assignment = RoleAssignment.new(
      user_id: @user.id,
      role_id: @role.id
    )

    assert_predicate assignment, :valid?
  end

  test "requires role_id" do
    assignment = RoleAssignment.new(
      user_id: @user.id
    )

    assert_predicate assignment, :invalid?
    assert_predicate assignment.errors[:role], :any?
  end

  test "requires either user_id or staff_id" do
    assignment = RoleAssignment.new(
      role_id: @role.id
    )

    assert_predicate assignment, :invalid?
    assert_predicate assignment.errors[:base], :any?
  end

  test "cannot assign to both user and staff" do
    staff = Staff.create!
    assignment = RoleAssignment.new(
      user_id: @user.id,
      staff_id: staff.id,
      role_id: @role.id
    )

    assert_predicate assignment, :invalid?
    assert_predicate assignment.errors[:base], :any?
  end

  test "belongs to user" do
    assignment = RoleAssignment.create!(
      user_id: @user.id,
      role_id: @role.id
    )

    assert_equal @user, assignment.user
  end

  test "has_one organization through role" do
    assignment = RoleAssignment.create!(
      user_id: @user.id,
      role_id: @role.id
    )

    assert_equal @organization, assignment.organization
  end

  test "belongs to role" do
    assignment = RoleAssignment.create!(
      user_id: @user.id,
      role_id: @role.id
    )

    assert_equal @role, assignment.role
  end

  test "user has many role_assignments" do
    assignment = RoleAssignment.create!(
      user_id: @user.id,
      role_id: @role.id
    )

    assert_includes @user.role_assignments, assignment
  end

  test "user has many roles through role_assignments" do
    assignment = RoleAssignment.create!(
      user_id: @user.id,
      role_id: @role.id
    )

    assert_includes @user.roles, @role
  end

  test "role has organization" do
    assignment = RoleAssignment.create!(
      user_id: @user.id,
      role_id: @role.id
    )

    assert_equal @organization, assignment.role.organization
  end
end
