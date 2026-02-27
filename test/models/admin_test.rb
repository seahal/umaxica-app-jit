# typed: false
# == Schema Information
#
# Table name: admins
# Database name: operator
#
#  id            :bigint           not null, primary key
#  lock_version  :integer          default(0), not null
#  moniker       :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  department_id :bigint
#  public_id     :string           not null
#  staff_id      :bigint           not null
#  status_id     :bigint           default(2), not null
#
# Indexes
#
#  index_admins_on_department_id  (department_id)
#  index_admins_on_public_id      (public_id) UNIQUE
#  index_admins_on_staff_id       (staff_id)
#  index_admins_on_status_id      (status_id)
#
# Foreign Keys
#
#  fk_rails_...  (department_id => departments.id) ON DELETE => nullify
#  fk_rails_...  (staff_id => staffs.id)
#  fk_rails_...  (status_id => admin_statuses.id)
#

# frozen_string_literal: true

require "test_helper"

class AdminTest < ActiveSupport::TestCase
  fixtures :staffs, :staff_statuses, :admins, :admin_statuses

  test "can create admin with staff" do
    staff = Staff.create!(public_id: "abcdef23")
    admin = Admin.create!(staff: staff)

    assert_predicate admin, :persisted?
    assert_equal staff, admin.staff
  end

  test "staff has many admins" do
    staff = Staff.create!(public_id: "abcdef24")
    admin = Admin.create!(staff: staff)

    assert_includes staff.admins, admin
  end

  test "belongs to staff" do
    staff = Staff.create!(public_id: "abcdef25")
    admin = Admin.create!(staff: staff)

    assert_equal staff, admin.staff
  end
end
