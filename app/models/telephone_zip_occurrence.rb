# == Schema Information
#
# Table name: telephone_zip_occurrences
#
#  id                      :uuid             not null, primary key
#  telephone_occurrence_id :uuid             not null
#  zip_occurrence_id       :uuid             not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_telephone_zip_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#  index_telephone_zip_occurrences_on_zip_occurrence_id        (zip_occurrence_id)
#

class TelephoneZipOccurrence < UniversalRecord
  self.implicit_order_column = :created_at

  belongs_to :telephone_occurrence
  belongs_to :zip_occurrence
end
