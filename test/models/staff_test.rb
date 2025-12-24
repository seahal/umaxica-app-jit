# == Schema Information
#
# Table name: staffs
#
#  id                       :uuid             not null, primary key
#  created_at               :datetime         not null
#  public_id                :string(21)       default(""), not null
#  staff_identity_status_id :string(255)      default("NONE"), not null
#  updated_at               :datetime         not null
#  webauthn_id              :string           default(""), not null
#  withdrawn_at             :datetime         default("infinity")
#
# Indexes
#
#  index_staffs_on_public_id                 (public_id) UNIQUE
#  index_staffs_on_staff_identity_status_id  (staff_identity_status_id)
#  index_staffs_on_withdrawn_at              (withdrawn_at)
#

require "test_helper"

class StaffTest < ActiveSupport::TestCase
  NIL_UUID = "00000000-0000-0000-0000-000000000000"

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

  test "should have many telephones association" do
    assert_equal "staff_id", @staff.class.reflect_on_association(:staff_identity_telephones).foreign_key
  end

  test "dependent behaviors for staff associations" do
    assert_equal :restrict_with_error,
                 Staff.reflect_on_association(:staff_identity_emails).options[:dependent]
    assert_equal :restrict_with_error,
                 Staff.reflect_on_association(:staff_identity_telephones).options[:dependent]
    assert_equal :nullify,
                 Staff.reflect_on_association(:staff_identity_audits).options[:dependent]
    assert_equal :nullify,
                 Staff.reflect_on_association(:user_identity_audits).options[:dependent]
    assert_equal :destroy,
                 Staff.reflect_on_association(:staff_identity_secrets).options[:dependent]
    assert_equal :nullify,
                 Staff.reflect_on_association(:staff_tokens).options[:dependent]
    assert_equal :nullify,
                 Staff.reflect_on_association(:staff_messages).options[:dependent]
    assert_equal :nullify,
                 Staff.reflect_on_association(:staff_notifications).options[:dependent]
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

  test "has_role? should correctly identify assigned roles" do
    workspace = Workspace.create!(
      name: "Test Workspace",
      domain: "staff-workspace.example.com",
      parent_organization: root_workspace.id
    )
    admin_role = Role.create!(key: "admin", name: "Admin", organization: workspace)
    Role.create!(key: "viewer", name: "Viewer", organization: workspace)

    RoleAssignment.create!(staff: @staff, role: admin_role)

    assert @staff.has_role?("admin")
    assert_not @staff.has_role?("viewer")
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
