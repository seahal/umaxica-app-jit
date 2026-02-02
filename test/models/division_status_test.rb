# frozen_string_literal: true

# == Schema Information
#
# Table name: division_statuses
# Database name: operator
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_division_statuses_on_code  (code) UNIQUE
#

require "test_helper"

class DivisionStatusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "validates length of id" do
    record = DivisionStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
