# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_telephone_occurrences
# Database name: occurrence
#
#  id                      :uuid             not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  staff_occurrence_id     :uuid             not null
#  telephone_occurrence_id :uuid             not null
#
# Indexes
#
#  index_staff_telephone_occurrences_on_staff_occurrence_id      (staff_occurrence_id)
#  index_staff_telephone_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (staff_occurrence_id => staff_occurrences.id)
#  fk_rails_...  (telephone_occurrence_id => telephone_occurrences.id)
#

class StaffTelephoneOccurrence < OccurrenceRecord
  belongs_to :staff_occurrence, inverse_of: :staff_telephone_occurrences
  belongs_to :telephone_occurrence, inverse_of: :staff_telephone_occurrences
end
