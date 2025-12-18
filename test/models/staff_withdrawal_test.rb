require "test_helper"

class StaffWithdrawalTest < ActiveSupport::TestCase
  test "staff can be marked withdrawn and permanently destroyed" do
    staff = Staff.create!(public_id: "eG8Bx3UDMOE60vxn_SR44")

    staff.update!(withdrawn_at: 31.days.ago)

    assert_predicate staff, :withdrawn?

    staff_id = staff.id
    staff.destroy

    assert_nil Staff.find_by(id: staff_id), "Staff should be removed after destroy"
  end
end
