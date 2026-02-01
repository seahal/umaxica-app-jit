# == Schema Information
#
# Table name: client_statuses
# Database name: principal
#
#  id :integer          not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class ClientStatusTest < ActiveSupport::TestCase
  test "NEYO constant" do
    assert_equal 0, ClientStatus::NEYO
  end

  test "validates id is non-negative" do
    record = ClientStatus.new(id: -1)
    assert_predicate record, :invalid?
    assert_includes record.errors[:id], "must be greater than or equal to 0"
  end

  test "validates id is an integer" do
    record = ClientStatus.new(id: 1.5)
    assert_predicate record, :invalid?
  end

  test "validates uniqueness of id" do
    ClientStatus.create!(id: 99)
    duplicate = ClientStatus.new(id: 99)
    assert_predicate duplicate, :invalid?
    assert_predicate duplicate.errors[:id], :any?
  end
end
