# frozen_string_literal: true

class ZipOccurrence < UniversalRecord
  belongs_to :zip_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :zip_occurrences
end
