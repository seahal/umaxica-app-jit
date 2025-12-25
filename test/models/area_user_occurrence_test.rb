# == Schema Information
#
# Table name: area_user_occurrences
#
#  id                 :uuid             not null, primary key
#  area_occurrence_id :uuid             not null
#  user_occurrence_id :uuid             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_area_user_occurrences_on_area_occurrence_id  (area_occurrence_id)
#  index_area_user_occurrences_on_user_occurrence_id  (user_occurrence_id)
#

require "test_helper"

class AreaUserOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
