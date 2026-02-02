# frozen_string_literal: true

# == Schema Information
#
# Table name: ip_telephone_occurrences
# Database name: occurrence
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  ip_occurrence_id        :bigint           not null
#  telephone_occurrence_id :bigint           not null
#
# Indexes
#
#  idx_ip_telephone_occ_on_ids                                (ip_occurrence_id,telephone_occurrence_id) UNIQUE
#  index_ip_telephone_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (ip_occurrence_id => ip_occurrences.id)
#  fk_rails_...  (telephone_occurrence_id => telephone_occurrences.id)
#

class IpTelephoneOccurrence < OccurrenceRecord
  belongs_to :ip_occurrence, inverse_of: :ip_telephone_occurrences
  belongs_to :telephone_occurrence, inverse_of: :ip_telephone_occurrences

  validates :ip_occurrence_id, uniqueness: { scope: :telephone_occurrence_id }
end
