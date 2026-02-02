# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_statuses
# Database name: avatar
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_handle_statuses_on_code  (code) UNIQUE
#

require "test_helper"

class HandleStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = HandleStatus.new(id: "TEST_STATUS")
    assert_predicate status, :valid?
  end

  test "can load active status from db" do
    status = HandleStatus.find("ACTIVE")
    assert_not_nil status
    assert_equal "ACTIVE", status.id
  end

  test "validates length of id" do
    record = HandleStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
