# typed: false
# frozen_string_literal: true

require "test_helper"

class StaffIdentifierDetectionTest < ActiveSupport::TestCase
  class DummyController
    include StaffIdentifierDetection
  end

  setup do
    @controller = DummyController.new
  end

  test "find_staff_by_identifier finds by staff email" do
    staff = Staff.create!
    StaffEmail.create!(staff: staff, address: "test@example.com")

    result = @controller.send(:find_staff_by_identifier, "test@example.com")

    assert_equal staff, result
  end

  test "find_staff_by_identifier finds by public id" do
    staff = Staff.create!

    result = @controller.send(:find_staff_by_identifier, staff.public_id)

    assert_equal staff, result
  end

  test "find_staff_by_identifier returns nil when not found" do
    result = @controller.send(:find_staff_by_identifier, "nonexistent@example.com")

    assert_nil result
  end
end
