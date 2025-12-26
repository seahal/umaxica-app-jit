# frozen_string_literal: true

# == Schema Information
#
# Table name: area_email_occurrences
#
#  id                  :uuid             not null, primary key
#  area_occurrence_id  :uuid             not null
#  email_occurrence_id :uuid             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_area_email_occurrences_on_area_occurrence_id   (area_occurrence_id)
#  index_area_email_occurrences_on_email_occurrence_id  (email_occurrence_id)
#

class AreaEmailOccurrence < UniversalRecord
  self.implicit_order_column = :created_at

  belongs_to :area_occurrence
  belongs_to :email_occurrence
end
