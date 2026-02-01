# frozen_string_literal: true

# == Schema Information
#
# Table name: area_ip_occurrences
# Database name: occurrence
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  area_occurrence_id :bigint           not null
#  ip_occurrence_id   :bigint           not null
#
# Indexes
#
#  idx_area_ip_occ_on_ids                           (area_occurrence_id,ip_occurrence_id) UNIQUE
#  index_area_ip_occurrences_on_area_occurrence_id  (area_occurrence_id)
#  index_area_ip_occurrences_on_ip_occurrence_id    (ip_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (area_occurrence_id => area_occurrences.id)
#  fk_rails_...  (ip_occurrence_id => ip_occurrences.id)
#

class AreaIpOccurrence < OccurrenceRecord
  belongs_to :area_occurrence, inverse_of: :area_ip_occurrences
  belongs_to :ip_occurrence, inverse_of: :area_ip_occurrences

  validates :area_occurrence_id, uniqueness: { scope: :ip_occurrence_id }
end
