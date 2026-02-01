# frozen_string_literal: true

# == Schema Information
#
# Table name: ip_zip_occurrences
# Database name: occurrence
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  ip_occurrence_id  :bigint           not null
#  zip_occurrence_id :bigint           not null
#
# Indexes
#
#  idx_ip_zip_occ_on_ids                          (ip_occurrence_id,zip_occurrence_id) UNIQUE
#  index_ip_zip_occurrences_on_ip_occurrence_id   (ip_occurrence_id)
#  index_ip_zip_occurrences_on_zip_occurrence_id  (zip_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (ip_occurrence_id => ip_occurrences.id)
#  fk_rails_...  (zip_occurrence_id => zip_occurrences.id)
#

class IpZipOccurrence < OccurrenceRecord
  belongs_to :ip_occurrence, inverse_of: :ip_zip_occurrences
  belongs_to :zip_occurrence, inverse_of: :ip_zip_occurrences

  validates :ip_occurrence_id, uniqueness: { scope: :zip_occurrence_id }
end
