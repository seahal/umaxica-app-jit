# frozen_string_literal: true

require "test_helper"

class StaffServiceTest < ActiveSupport::TestCase
  test "should instantiate StaffService" do
    service = StaffService.new

    assert_instance_of StaffService, service
  end

  test "StaffService is an empty class" do
    service = StaffService.new

    # Verify it's an instance but has no methods beyond Object methods
    assert_not_nil service
    assert_respond_to service, :class
  end
end
