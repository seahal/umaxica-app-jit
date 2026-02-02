# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_statuses
# Database name: operator
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_admin_statuses_on_code  (code) UNIQUE
#
require "test_helper"

class AdminStatusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "validates length of id" do
    record = AdminStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
