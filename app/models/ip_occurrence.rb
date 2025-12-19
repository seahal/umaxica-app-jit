# frozen_string_literal: true

class IpOccurrence < UniversalRecord
  belongs_to :ip_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :ip_occurrences
end
