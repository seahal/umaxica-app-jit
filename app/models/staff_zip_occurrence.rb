# == Schema Information
#
# Table name: staff_zip_occurrences
#
#  id                  :uuid             not null, primary key
#  staff_occurrence_id :uuid             not null
#  zip_occurrence_id   :uuid             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_staff_zip_occurrences_on_staff_occurrence_id  (staff_occurrence_id)
#  index_staff_zip_occurrences_on_zip_occurrence_id    (zip_occurrence_id)
#

class StaffZipOccurrence < UniversalRecord
  self.implicit_order_column = :created_at

  belongs_to :staff_occurrence
  belongs_to :zip_occurrence
end
