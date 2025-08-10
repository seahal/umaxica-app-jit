# frozen_string_literal: true

require "test_helper"

class StaffEmailStaffTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end

  test "email staff relation" do
    assert StaffEmail.create(id: "10001010101", address: "one2@example.com").valid?
  end
end
