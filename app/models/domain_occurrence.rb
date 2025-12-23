class DomainOccurrence < UniversalRecord
  include PublicId
  include Occurrence

  belongs_to :domain_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :domain_occurrences
end
