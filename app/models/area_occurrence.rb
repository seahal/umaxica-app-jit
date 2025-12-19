# frozen_string_literal: true

class AreaOccurrence < UniversalRecord
  belongs_to :area_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :area_occurrences
end
