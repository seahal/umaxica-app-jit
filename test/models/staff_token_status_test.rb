# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_token_statuses
# Database name: token
#
#  id :bigint           not null, primary key
#

require "test_helper"

class StaffTokenStatusTest < ActiveSupport::TestCase
  test "accepts integer ids" do
    status = StaffTokenStatus.new(id: 9)
    assert_predicate status, :valid?
  end

  test "constants are defined" do
    assert_equal 1, StaffTokenStatus::ACTIVE
    assert_equal 2, StaffTokenStatus::NEYO
  end
end
