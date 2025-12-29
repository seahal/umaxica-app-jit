# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_telephone_occurrences
#
#  id                      :uuid             not null, primary key
#  domain_occurrence_id    :uuid             not null
#  telephone_occurrence_id :uuid             not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_domain_telephone_occurrences_on_domain_occurrence_id     (domain_occurrence_id)
#  index_domain_telephone_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#

class DomainTelephoneOccurrence < UniversalRecord
  self.implicit_order_column = :created_at

  belongs_to :domain_occurrence, inverse_of: :domain_telephone_occurrences
  belongs_to :telephone_occurrence, inverse_of: :domain_telephone_occurrences
end
