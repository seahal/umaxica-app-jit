# frozen_string_literal: true

# == Schema Information
#
# Table name: area_domain_occurrences
# Database name: occurrence
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  area_occurrence_id   :bigint           not null
#  domain_occurrence_id :bigint           not null
#
# Indexes
#
#  idx_area_domain_occ_on_ids                             (area_occurrence_id,domain_occurrence_id) UNIQUE
#  index_area_domain_occurrences_on_area_occurrence_id    (area_occurrence_id)
#  index_area_domain_occurrences_on_domain_occurrence_id  (domain_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (area_occurrence_id => area_occurrences.id)
#  fk_rails_...  (domain_occurrence_id => domain_occurrences.id)
#

class AreaDomainOccurrence < OccurrenceRecord
  belongs_to :area_occurrence, inverse_of: :area_domain_occurrences
  belongs_to :domain_occurrence, inverse_of: :area_domain_occurrences

  validates :area_occurrence_id, uniqueness: { scope: :domain_occurrence_id }
end
