# frozen_string_literal: true

# == Schema Information
#
# Table name: email_user_occurrences
# Database name: occurrence
#
#  id                  :uuid             not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  email_occurrence_id :uuid             not null
#  user_occurrence_id  :uuid             not null
#
# Indexes
#
#  index_email_user_occurrences_on_email_occurrence_id  (email_occurrence_id)
#  index_email_user_occurrences_on_user_occurrence_id   (user_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_occurrence_id => email_occurrences.id)
#  fk_rails_...  (user_occurrence_id => user_occurrences.id)
#

class EmailUserOccurrence < OccurrenceRecord
  belongs_to :email_occurrence, inverse_of: :email_user_occurrences
  belongs_to :user_occurrence, inverse_of: :email_user_occurrences
end
