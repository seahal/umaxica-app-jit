# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: operators
# Database name: operator
#
#  id            :bigint           not null, primary key
#  lock_version  :integer          default(0), not null
#  moniker       :string
#  shreddable_at :datetime         default(Infinity), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  department_id :bigint
#  public_id     :string           not null
#  staff_id      :bigint           not null
#  status_id     :bigint           default(2), not null
#
# Indexes
#
#  index_operators_on_department_id  (department_id)
#  index_operators_on_public_id      (public_id) UNIQUE
#  index_operators_on_shreddable_at  (shreddable_at)
#  index_operators_on_staff_id       (staff_id)
#  index_operators_on_status_id      (status_id)
#
# Foreign Keys
#
#  fk_rails_...  (department_id => departments.id) ON DELETE => nullify
#  fk_rails_...  (staff_id => staffs.id)
#  fk_rails_...  (status_id => operator_statuses.id)
#
require "test_helper"

class OperatorTest < ActiveSupport::TestCase
  fixtures :staffs, :staff_statuses, :operators, :operator_statuses

  test "can create operator with staff" do
    staff = Staff.create!(public_id: "ABCDEFGH2345WXYZ")
    operator = Operator.create!(staff: staff)

    assert_predicate operator, :persisted?
    assert_equal staff, operator.staff
  end

  test "staff has many operators" do
    staff = Staff.create!(public_id: "ABCDEFGH2345WXY2")
    operator = Operator.create!(staff: staff)

    assert_includes staff.operators, operator
  end

  test "belongs to staff" do
    staff = Staff.create!(public_id: "ABCDEFGH2345WXY3")
    operator = Operator.create!(staff: staff)

    assert_equal staff, operator.staff
  end

  test "shreddable scope excludes operators with shreddable_at in the future" do
    staff = Staff.create!(public_id: "ABCDEFGH2345WXY4")
    operator = Operator.create!(staff: staff)

    assert_not_includes Operator.shreddable, operator
  end

  test "shreddable scope includes operators with shreddable_at in the past" do
    staff = Staff.create!(public_id: "ABCDEFGH2345WXY5")
    operator = Operator.create!(staff: staff, shreddable_at: 1.second.ago)

    assert_includes Operator.shreddable, operator
  end
end
