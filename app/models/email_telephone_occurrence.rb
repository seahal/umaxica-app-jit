# frozen_string_literal: true

# == Schema Information
#
# Table name: email_telephone_occurrences
# Database name: occurrence
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  email_occurrence_id     :bigint           not null
#  telephone_occurrence_id :bigint           not null
#
# Indexes
#
#  idx_email_telephone_occ_on_ids                                (email_occurrence_id,telephone_occurrence_id) UNIQUE
#  index_email_telephone_occurrences_on_email_occurrence_id      (email_occurrence_id)
#  index_email_telephone_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_occurrence_id => email_occurrences.id)
#  fk_rails_...  (telephone_occurrence_id => telephone_occurrences.id)
#

class EmailTelephoneOccurrence < OccurrenceRecord
  belongs_to :email_occurrence, inverse_of: :email_telephone_occurrences
  belongs_to :telephone_occurrence, inverse_of: :email_telephone_occurrences

  validates :email_occurrence_id, uniqueness: { scope: :telephone_occurrence_id }
end
