# frozen_string_literal: true

# == Schema Information
#
# Table name: ip_user_occurrences
# Database name: occurrence
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  ip_occurrence_id   :bigint           not null
#  user_occurrence_id :bigint           not null
#
# Indexes
#
#  idx_ip_user_occ_on_ids                           (ip_occurrence_id,user_occurrence_id) UNIQUE
#  index_ip_user_occurrences_on_ip_occurrence_id    (ip_occurrence_id)
#  index_ip_user_occurrences_on_user_occurrence_id  (user_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (ip_occurrence_id => ip_occurrences.id)
#  fk_rails_...  (user_occurrence_id => user_occurrences.id)
#

class IpUserOccurrence < OccurrenceRecord
  belongs_to :ip_occurrence, inverse_of: :ip_user_occurrences
  belongs_to :user_occurrence, inverse_of: :ip_user_occurrences

  validates :ip_occurrence_id, uniqueness: { scope: :user_occurrence_id }
end
