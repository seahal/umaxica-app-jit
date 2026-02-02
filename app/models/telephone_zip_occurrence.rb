# frozen_string_literal: true

# == Schema Information
#
# Table name: telephone_zip_occurrences
# Database name: occurrence
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  telephone_occurrence_id :bigint           not null
#  zip_occurrence_id       :bigint           not null
#
# Indexes
#
#  idx_telephone_zip_occ_on_ids                          (telephone_occurrence_id,zip_occurrence_id) UNIQUE
#  index_telephone_zip_occurrences_on_zip_occurrence_id  (zip_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (telephone_occurrence_id => telephone_occurrences.id)
#  fk_rails_...  (zip_occurrence_id => zip_occurrences.id)
#

class TelephoneZipOccurrence < OccurrenceRecord
  belongs_to :telephone_occurrence, inverse_of: :telephone_zip_occurrences
  belongs_to :zip_occurrence, inverse_of: :telephone_zip_occurrences

  validates :telephone_occurrence_id, uniqueness: { scope: :zip_occurrence_id }
end
