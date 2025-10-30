# == Schema Information
#
# Table name: staff_time_based_one_time_passwords
#
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  staff_id                        :uuid             not null
#  time_based_one_time_password_id :uuid             not null
#
require "test_helper"

class StaffTimeBasedOneTimePasswordTest < ActiveSupport::TestCase
  test "inherits from IdentifiersRecord" do
    assert_operator StaffTimeBasedOneTimePassword, :<, IdentifiersRecord
  end

  test "belongs to staff" do
    association = StaffTimeBasedOneTimePassword.reflect_on_association(:staff)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "allows assignment of staff without database" do
    staff = Staff.new
    pivot = StaffTimeBasedOneTimePassword.new(staff:)

    assert_same staff, pivot.staff
  end
end
