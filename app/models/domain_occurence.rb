# frozen_string_literal: true

class DomainOccurence < UniversalRecord
  include Occurrence

  belongs_to :domain_occurence_status, foreign_key: :status_id, optional: true, inverse_of: :domain_occurences
end
