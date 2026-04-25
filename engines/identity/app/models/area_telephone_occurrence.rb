# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: area_telephone_occurrences
# Database name: occurrence
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  area_occurrence_id      :bigint           not null
#  telephone_occurrence_id :bigint           not null
#
# Indexes
#
#  idx_area_telephone_occ_on_ids                                (area_occurrence_id,telephone_occurrence_id) UNIQUE
#  index_area_telephone_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (area_occurrence_id => area_occurrences.id)
#  fk_rails_...  (telephone_occurrence_id => telephone_occurrences.id)
#

class AreaTelephoneOccurrence < OccurrenceRecord
  belongs_to :area_occurrence, inverse_of: :area_telephone_occurrences
  belongs_to :telephone_occurrence, inverse_of: :area_telephone_occurrences

  validates :area_occurrence_id, uniqueness: { scope: :telephone_occurrence_id }
end
