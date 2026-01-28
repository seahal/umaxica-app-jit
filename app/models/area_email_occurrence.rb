# frozen_string_literal: true

# == Schema Information
#
# Table name: area_email_occurrences
# Database name: occurrence
#
#  id                  :uuid             not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  area_occurrence_id  :uuid             not null
#  email_occurrence_id :uuid             not null
#
# Indexes
#
#  index_area_email_occurrences_on_area_occurrence_id   (area_occurrence_id)
#  index_area_email_occurrences_on_email_occurrence_id  (email_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (area_occurrence_id => area_occurrences.id)
#  fk_rails_...  (email_occurrence_id => email_occurrences.id)
#

class AreaEmailOccurrence < OccurrenceRecord
  belongs_to :area_occurrence, inverse_of: :area_email_occurrences
  belongs_to :email_occurrence, inverse_of: :area_email_occurrences
end
