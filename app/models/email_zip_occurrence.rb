# frozen_string_literal: true

# == Schema Information
#
# Table name: email_zip_occurrences
#
#  id                  :uuid             not null, primary key
#  email_occurrence_id :uuid             not null
#  zip_occurrence_id   :uuid             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_email_zip_occurrences_on_email_occurrence_id  (email_occurrence_id)
#  index_email_zip_occurrences_on_zip_occurrence_id    (zip_occurrence_id)
#

class EmailZipOccurrence < UniversalRecord
  belongs_to :email_occurrence, inverse_of: :email_zip_occurrences
  belongs_to :zip_occurrence, inverse_of: :email_zip_occurrences
end
