# frozen_string_literal: true

class TelephoneOccurrence < UniversalRecord
  belongs_to :telephone_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :telephone_occurrences
end
