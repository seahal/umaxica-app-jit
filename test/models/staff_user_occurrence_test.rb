# == Schema Information
#
# Table name: staff_user_occurrences
#
#  id                  :uuid             not null, primary key
#  staff_occurrence_id :uuid             not null
#  user_occurrence_id  :uuid             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_staff_user_occurrences_on_staff_occurrence_id  (staff_occurrence_id)
#  index_staff_user_occurrences_on_user_occurrence_id   (user_occurrence_id)
#

require "test_helper"

class StaffUserOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
