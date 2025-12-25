# == Schema Information
#
# Table name: area_zip_occurrences
#
#  id                 :uuid             not null, primary key
#  area_occurrence_id :uuid             not null
#  zip_occurrence_id  :uuid             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_area_zip_occurrences_on_area_occurrence_id  (area_occurrence_id)
#  index_area_zip_occurrences_on_zip_occurrence_id   (zip_occurrence_id)
#

class AreaZipOccurrence < UniversalRecord
  self.implicit_order_column = :created_at

  belongs_to :area_occurrence
  belongs_to :zip_occurrence
end
