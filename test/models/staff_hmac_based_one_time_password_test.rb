# == Schema Information
#
# Table name: staff_hmac_based_one_time_passwords
#
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  hmac_based_one_time_password_id :binary           not null
#  staff_id                        :binary           not null
#
require "test_helper"

class StaffHmacBasedOneTimePasswordTest < ActiveSupport::TestCase
  test "inherits from IdentitiesRecord" do
    assert_operator StaffHmacBasedOneTimePassword, :<, IdentitiesRecord
  end

  test "belongs to staff" do
    association = StaffHmacBasedOneTimePassword.reflect_on_association(:staff)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "belongs to hmac_based_one_time_password" do
    association = StaffHmacBasedOneTimePassword.reflect_on_association(:hmac_based_one_time_password)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  # test "loads staff and hmac associations from fixtures" do
  #   record = staff_hmac_based_one_time_passwords(:one)

  #   assert_equal staffs(:one), record.staff
  #   assert_equal hmac_based_one_time_passwords(:one), record.hmac_based_one_time_password
  # end

  test "allows assignment of associations before persistence" do
    staff = staffs(:one)
    hmac = hmac_based_one_time_passwords(:one)

    record = StaffHmacBasedOneTimePassword.new(staff:, hmac_based_one_time_password: hmac)

    assert_same staff, record.staff
    assert_same hmac, record.hmac_based_one_time_password
  end
end
