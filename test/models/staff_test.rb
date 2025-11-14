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
end
