# frozen_string_literal: true

# == Schema Information
#
# Table name: user_occurrence_statuses
# Database name: occurrence
#
#  id :string(255)      default("NEYO"), not null, primary key
#
# Indexes
#
#  index_user_occurrence_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

require "test_helper"

class UserOccurrenceStatusTest < ActiveSupport::TestCase
  #   test "expires_at default" do
  #     record = UserOccurrenceStatus.new(id: "EXPIRES_AT_TEST")
  #
  #     assert_expires_at_default(record)
  #   end

  test "validates length of id" do
    record = UserOccurrenceStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
