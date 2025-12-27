# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_occurrence_statuses
#
#  id         :string(255)      default("NONE"), not null, primary key
#  expires_at :datetime         not null
#
# Indexes
#
#  index_staff_occurrence_statuses_on_expires_at  (expires_at)
#

require "test_helper"

class StaffOccurrenceStatusTest < ActiveSupport::TestCase
  include OccurrenceStatusTestHelper

  test "expires_at default" do
    record = StaffOccurrenceStatus.new(id: "EXPIRES_AT_TEST")

    assert_expires_at_default(record)
  end
end
