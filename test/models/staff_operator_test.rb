# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_operators
# Database name: operator
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  operator_id :bigint           not null
#  staff_id    :bigint           not null
#
# Indexes
#
#  index_staff_operators_on_operator_id               (operator_id)
#  index_staff_operators_on_staff_id_and_operator_id  (staff_id,operator_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (operator_id => operators.id) ON DELETE => cascade
#  fk_rails_...  (staff_id => staffs.id) ON DELETE => cascade
#

require "test_helper"

class StaffOperatorTest < ActiveSupport::TestCase
  def setup
    @staff = Staff.create!
    @operator = operators(:operator_one)
  end

  test "should be valid with staff and operator" do
    staff_operator = StaffOperator.new(
      staff: @staff,
      operator: @operator,
    )

    assert_predicate staff_operator, :valid?
  end

  test "should require staff" do
    staff_operator = StaffOperator.new(
      operator: @operator,
    )

    assert_not staff_operator.valid?
    assert_not_empty staff_operator.errors[:staff]
  end

  test "should require operator" do
    staff_operator = StaffOperator.new(
      staff: @staff,
    )

    assert_not staff_operator.valid?
    assert_not_empty staff_operator.errors[:operator]
  end

  test "operator_id must be unique scoped to staff_id" do
    StaffOperator.create!(
      staff: @staff,
      operator: @operator,
    )

    duplicate = StaffOperator.new(
      staff: @staff,
      operator: @operator,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:operator_id]
  end

  test "same operator with different staff is allowed" do
    StaffOperator.create!(
      staff: @staff,
      operator: @operator,
    )

    other_staff = Staff.create!
    different_staff_operator = StaffOperator.new(
      staff: other_staff,
      operator: @operator,
    )

    assert_predicate different_staff_operator, :valid?
  end

  test "same staff with different operators is allowed" do
    StaffOperator.create!(
      staff: @staff,
      operator: @operator,
    )

    other_operator = operators(:operator_two)
    different_operator = StaffOperator.new(
      staff: @staff,
      operator: other_operator,
    )

    assert_predicate different_operator, :valid?
  end

  test "belongs to staff" do
    staff_operator = StaffOperator.create!(
      staff: @staff,
      operator: @operator,
    )

    assert_equal @staff, staff_operator.staff
  end

  test "belongs to operator" do
    staff_operator = StaffOperator.create!(
      staff: @staff,
      operator: @operator,
    )

    assert_equal @operator, staff_operator.operator
  end

  test "association: operator has many staffs through staff_operators" do
    StaffOperator.create!(
      staff: @staff,
      operator: @operator,
    )

    assert_includes @operator.staffs, @staff
  end
end
