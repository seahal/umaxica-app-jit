# frozen_string_literal: true

# == Schema Information
#
# Table name: area_zip_occurrences
# Database name: occurrence
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  area_occurrence_id :bigint           not null
#  zip_occurrence_id  :bigint           not null
#
# Indexes
#
#  idx_area_zip_occ_on_ids                           (area_occurrence_id,zip_occurrence_id) UNIQUE
#  index_area_zip_occurrences_on_area_occurrence_id  (area_occurrence_id)
#  index_area_zip_occurrences_on_zip_occurrence_id   (zip_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (area_occurrence_id => area_occurrences.id)
#  fk_rails_...  (zip_occurrence_id => zip_occurrences.id)
#

class AreaZipOccurrence < OccurrenceRecord
  belongs_to :area_occurrence, inverse_of: :area_zip_occurrences
  belongs_to :zip_occurrence, inverse_of: :area_zip_occurrences

  validates :area_occurrence_id, uniqueness: { scope: :zip_occurrence_id }
end
