# frozen_string_literal: true

# == Schema Information
#
# Table name: area_staff_occurrences
#
#  id                  :uuid             not null, primary key
#  area_occurrence_id  :uuid             not null
#  staff_occurrence_id :uuid             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_area_staff_occurrences_on_area_occurrence_id   (area_occurrence_id)
#  index_area_staff_occurrences_on_staff_occurrence_id  (staff_occurrence_id)
#

require "test_helper"

class AreaStaffOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
