# frozen_string_literal: true

require "test_helper"

class UserSocialAppleStatusTest < ActiveSupport::TestCase
  test "valid status" do
    status = UserSocialAppleStatus.new(id: "TEST_STATUS")
    assert_predicate status, :valid?
    assert status.save
    assert_equal "TEST_STATUS", status.id
  end

  test "upcases id" do
    status = UserSocialAppleStatus.new(id: "lower")
    status.valid?
    assert_equal "LOWER", status.id
  end
end
