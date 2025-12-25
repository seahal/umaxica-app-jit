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
  self.implicit_order_column = :created_at

  belongs_to :email_occurrence
  belongs_to :zip_occurrence
end
