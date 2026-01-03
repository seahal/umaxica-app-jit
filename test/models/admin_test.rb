# == Schema Information
#
# Table name: admins
#
#  id            :uuid             not null, primary key
#  public_id     :string
#  moniker       :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  status_id     :string(255)      default("NEYO"), not null
#  staff_id      :uuid             not null
#  department_id :uuid
#
# Indexes
#
#  index_admins_on_department_id  (department_id)
#  index_admins_on_public_id      (public_id) UNIQUE
#  index_admins_on_staff_id       (staff_id)
#  index_admins_on_status_id      (status_id)
#

# frozen_string_literal: true

require "test_helper"

class AdminTest < ActiveSupport::TestCase
  test "belongs to staff" do
    staff = staffs(:one)
    admin = Admin.new(staff: staff)
    assert_equal staff, admin.staff
  end

  test "can create admin with staff" do
    staff = staffs(:one)
    admin = Admin.create!(staff: staff)
    assert_not_nil admin.staff_id
    assert_equal staff.id, admin.staff_id
  end

  test "staff has many admins" do
    staff = staffs(:one)
    assert_includes staff.admins, admins(:admin_one)
  end
end
