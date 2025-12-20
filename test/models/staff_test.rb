# == Schema Information
#
# Table name: staffs
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  webauthn_id :string
#
require "test_helper"

class StaffTest < ActiveSupport::TestCase
  def setup
    @staff = staffs(:one)
  end

  test "should be valid" do
    assert_predicate @staff, :valid?
  end

  test "should have timestamps" do
    assert_not_nil @staff.created_at
    assert_not_nil @staff.updated_at
  end

  test "should have many emails association" do
    assert_respond_to @staff, :emails
    assert_equal "staff_id", @staff.class.reflect_on_association(:staff_identity_emails).foreign_key
  end

  test "should have many telephones association" do
    assert_equal "staff_id", @staff.class.reflect_on_association(:staff_identity_telephones).foreign_key
  end

  test "staff? should return true" do
    assert_predicate @staff, :staff?
  end

  test "user? should return false" do
    assert_not @staff.user?
  end

  test "should set default status before creation" do
    staff = Staff.create!

    assert_equal StaffIdentityStatus::NONE, staff.staff_identity_status_id
  end

  test "set_default_status assigns fallback when missing" do
    staff = Staff.new

    staff.send(:set_default_status)

    assert_equal StaffIdentityStatus::NONE, staff.staff_identity_status_id
  end

  test "has_role? should correctly identify assigned roles" do
    workspace = Workspace.create!(name: "Test Workspace")
    admin_role = Role.create!(key: "admin", name: "Admin", organization: workspace)
    viewer_role = Role.create!(key: "viewer", name: "Viewer", organization: workspace)

    RoleAssignment.create!(staff: @staff, role: admin_role)

    assert @staff.has_role?("admin")
    assert_not @staff.has_role?("viewer")
  end
end
