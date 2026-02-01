# frozen_string_literal: true

# == Schema Information
#
# Table name: area_staff_occurrences
# Database name: occurrence
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  area_occurrence_id  :bigint           not null
#  staff_occurrence_id :bigint           not null
#
# Indexes
#
#  idx_area_staff_occ_on_ids                            (area_occurrence_id,staff_occurrence_id) UNIQUE
#  index_area_staff_occurrences_on_area_occurrence_id   (area_occurrence_id)
#  index_area_staff_occurrences_on_staff_occurrence_id  (staff_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (area_occurrence_id => area_occurrences.id)
#  fk_rails_...  (staff_occurrence_id => staff_occurrences.id)
#

require "test_helper"

class AreaStaffOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
