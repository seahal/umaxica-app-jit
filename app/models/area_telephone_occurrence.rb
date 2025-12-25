# == Schema Information
#
# Table name: area_telephone_occurrences
#
#  id                      :uuid             not null, primary key
#  area_occurrence_id      :uuid             not null
#  telephone_occurrence_id :uuid             not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_area_telephone_occurrences_on_area_occurrence_id       (area_occurrence_id)
#  index_area_telephone_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#

class AreaTelephoneOccurrence < UniversalRecord
  self.implicit_order_column = :created_at

  belongs_to :area_occurrence
  belongs_to :telephone_occurrence
end
