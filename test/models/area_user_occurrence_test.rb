# frozen_string_literal: true

# == Schema Information
#
# Table name: area_user_occurrences
# Database name: occurrence
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  area_occurrence_id :bigint           not null
#  user_occurrence_id :bigint           not null
#
# Indexes
#
#  idx_area_user_occ_on_ids                           (area_occurrence_id,user_occurrence_id) UNIQUE
#  index_area_user_occurrences_on_area_occurrence_id  (area_occurrence_id)
#  index_area_user_occurrences_on_user_occurrence_id  (user_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (area_occurrence_id => area_occurrences.id)
#  fk_rails_...  (user_occurrence_id => user_occurrences.id)
#

require "test_helper"

class AreaUserOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
