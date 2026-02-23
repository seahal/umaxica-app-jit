# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: zip_occurrence_statuses
# Database name: occurrence
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ZipOccurrenceStatusTest < ActiveSupport::TestCase
  test "accepts integer ids" do
    record = ZipOccurrenceStatus.new(id: 3)
    assert_predicate record, :valid?
  end

  test "has occurrences association" do
    assert_status_association(ZipOccurrenceStatus, :zip_occurrences)
  end

  #   test "expires_at default" do
  #     record = ZipOccurrenceStatus.new(id: "EXPIRES_AT_TEST")
  #
  #     assert_expires_at_default(record)
  #   end
end
