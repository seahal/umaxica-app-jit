# frozen_string_literal: true

# == Schema Information
#
# Table name: telephone_user_occurrences
#
#  id                      :uuid             not null, primary key
#  telephone_occurrence_id :uuid             not null
#  user_occurrence_id      :uuid             not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_telephone_user_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#  index_telephone_user_occurrences_on_user_occurrence_id       (user_occurrence_id)
#

class TelephoneUserOccurrence < UniversalRecord
  self.implicit_order_column = :created_at

  belongs_to :telephone_occurrence
  belongs_to :user_occurrence
end
