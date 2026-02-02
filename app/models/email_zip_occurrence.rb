# frozen_string_literal: true

# == Schema Information
#
# Table name: email_zip_occurrences
# Database name: occurrence
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  email_occurrence_id :bigint           not null
#  zip_occurrence_id   :bigint           not null
#
# Indexes
#
#  idx_email_zip_occ_on_ids                          (email_occurrence_id,zip_occurrence_id) UNIQUE
#  index_email_zip_occurrences_on_zip_occurrence_id  (zip_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_occurrence_id => email_occurrences.id)
#  fk_rails_...  (zip_occurrence_id => zip_occurrences.id)
#

class EmailZipOccurrence < OccurrenceRecord
  belongs_to :email_occurrence, inverse_of: :email_zip_occurrences
  belongs_to :zip_occurrence, inverse_of: :email_zip_occurrences

  validates :email_occurrence_id, uniqueness: { scope: :zip_occurrence_id }
end
