# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_statuses
# Database name: operator
#
#  id :bigint           not null, primary key
#
require "test_helper"

class AdminStatusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "accepts integer ids" do
    record = AdminStatus.new(id: 9)

    assert_predicate record, :valid?
  end

  test "constants are defined" do
    assert_equal 1, AdminStatus::ACTIVE
    assert_equal 2, AdminStatus::NOTHING
  end
end
