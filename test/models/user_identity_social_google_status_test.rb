# frozen_string_literal: true

require "test_helper"

class UserIdentitySocialGoogleStatusTest < ActiveSupport::TestCase
  test "valid status" do
    status = UserIdentitySocialGoogleStatus.new(id: "TEST_STATUS")
    assert_predicate status, :valid?
    assert status.save
    assert_equal "TEST_STATUS", status.id
  end

  test "upcases id" do
    status = UserIdentitySocialGoogleStatus.new(id: "lower")
    status.valid?
    assert_equal "LOWER", status.id
  end
end
