# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_user_occurrences
# Database name: occurrence
#
#  id                  :uuid             not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  staff_occurrence_id :uuid             not null
#  user_occurrence_id  :uuid             not null
#
# Indexes
#
#  index_staff_user_occurrences_on_staff_occurrence_id  (staff_occurrence_id)
#  index_staff_user_occurrences_on_user_occurrence_id   (user_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (staff_occurrence_id => staff_occurrences.id)
#  fk_rails_...  (user_occurrence_id => user_occurrences.id)
#

class StaffUserOccurrence < OccurrenceRecord
  belongs_to :staff_occurrence, inverse_of: :staff_user_occurrences
  belongs_to :user_occurrence, inverse_of: :staff_user_occurrences
end
