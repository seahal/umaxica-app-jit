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
  belongs_to :area_occurrence, inverse_of: :area_email_occurrences
  belongs_to :email_occurrence, inverse_of: :area_email_occurrences
end
