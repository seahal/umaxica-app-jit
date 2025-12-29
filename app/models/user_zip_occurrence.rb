# frozen_string_literal: true

# == Schema Information
#
# Table name: user_zip_occurrences
#
#  id                 :uuid             not null, primary key
#  user_occurrence_id :uuid             not null
#  zip_occurrence_id  :uuid             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_user_zip_occurrences_on_user_occurrence_id  (user_occurrence_id)
#  index_user_zip_occurrences_on_zip_occurrence_id   (zip_occurrence_id)
#

class UserZipOccurrence < UniversalRecord
  self.implicit_order_column = :created_at

  belongs_to :user_occurrence, inverse_of: :user_zip_occurrences
  belongs_to :zip_occurrence, inverse_of: :user_zip_occurrences
end
