# frozen_string_literal: true

# == Schema Information
#
# Table name: area_user_occurrences
# Database name: occurrence
#
#  id                 :uuid             not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  area_occurrence_id :uuid             not null
#  user_occurrence_id :uuid             not null
#
# Indexes
#
#  index_area_user_occurrences_on_area_occurrence_id  (area_occurrence_id)
#  index_area_user_occurrences_on_user_occurrence_id  (user_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (area_occurrence_id => area_occurrences.id)
#  fk_rails_...  (user_occurrence_id => user_occurrences.id)
#

class AreaUserOccurrence < OccurrenceRecord
  belongs_to :area_occurrence, inverse_of: :area_user_occurrences
  belongs_to :user_occurrence, inverse_of: :area_user_occurrences
end
