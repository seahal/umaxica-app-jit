# frozen_string_literal: true

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
  belongs_to :telephone_occurrence, inverse_of: :telephone_zip_occurrences
  belongs_to :zip_occurrence, inverse_of: :telephone_zip_occurrences
end
