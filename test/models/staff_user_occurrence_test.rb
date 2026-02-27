# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_user_occurrences
# Database name: occurrence
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  staff_occurrence_id :bigint           not null
#  user_occurrence_id  :bigint           not null
#
# Indexes
#
#  idx_staff_user_occ_on_ids                           (staff_occurrence_id,user_occurrence_id) UNIQUE
#  index_staff_user_occurrences_on_user_occurrence_id  (user_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (staff_occurrence_id => staff_occurrences.id)
#  fk_rails_...  (user_occurrence_id => user_occurrences.id)
#

require "test_helper"

class StaffUserOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
