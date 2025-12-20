# frozen_string_literal: true

class DomainOccurrence < UniversalRecord
  include PublicId
  include Occurrence

  self.table_name = "domain_occurences"

  belongs_to :domain_occurence_status, foreign_key: :status_id, optional: true, inverse_of: :domain_occurences
end
