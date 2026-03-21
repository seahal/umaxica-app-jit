# typed: false
# frozen_string_literal: true

require "test_helper"

class StaffTokenBindingMethodTest < ActiveSupport::TestCase
  test "constants are defined correctly" do
    assert_equal 0, StaffTokenBindingMethod::NOTHING
    assert_equal 1, StaffTokenBindingMethod::DBSC
    assert_equal 2, StaffTokenBindingMethod::LEGACY
    assert_equal [0, 1, 2], StaffTokenBindingMethod::DEFAULTS
  end

  test "ensure_defaults! creates missing records" do
    StaffTokenBindingMethod.where(id: StaffTokenBindingMethod::DEFAULTS).destroy_all

    StaffTokenBindingMethod.ensure_defaults!

    assert StaffTokenBindingMethod.exists?(id: StaffTokenBindingMethod::NOTHING)
    assert StaffTokenBindingMethod.exists?(id: StaffTokenBindingMethod::DBSC)
    assert StaffTokenBindingMethod.exists?(id: StaffTokenBindingMethod::LEGACY)
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    StaffTokenBindingMethod.ensure_defaults!
    initial_count = StaffTokenBindingMethod.count

    StaffTokenBindingMethod.ensure_defaults!

    assert_equal initial_count, StaffTokenBindingMethod.count
  end

  test "has_many staff_tokens association" do
    method = StaffTokenBindingMethod.new(id: 1)
    assert_respond_to method, :staff_tokens
  end
end
