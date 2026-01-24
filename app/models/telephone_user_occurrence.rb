# frozen_string_literal: true

# == Schema Information
#
# Table name: telephone_user_occurrences
# Database name: occurrence
#
#  id                      :uuid             not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  telephone_occurrence_id :uuid             not null
#  user_occurrence_id      :uuid             not null
#
# Indexes
#
#  index_telephone_user_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#  index_telephone_user_occurrences_on_user_occurrence_id       (user_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (telephone_occurrence_id => telephone_occurrences.id)
#  fk_rails_...  (user_occurrence_id => user_occurrences.id)
#

class TelephoneUserOccurrence < OccurrenceRecord
  belongs_to :telephone_occurrence, inverse_of: :telephone_user_occurrences
  belongs_to :user_occurrence, inverse_of: :telephone_user_occurrences
end
