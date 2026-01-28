# frozen_string_literal: true

# == Schema Information
#
# Table name: email_ip_occurrences
# Database name: occurrence
#
#  id                  :uuid             not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  email_occurrence_id :uuid             not null
#  ip_occurrence_id    :uuid             not null
#
# Indexes
#
#  index_email_ip_occurrences_on_email_occurrence_id  (email_occurrence_id)
#  index_email_ip_occurrences_on_ip_occurrence_id     (ip_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_occurrence_id => email_occurrences.id)
#  fk_rails_...  (ip_occurrence_id => ip_occurrences.id)
#

class EmailIpOccurrence < OccurrenceRecord
  belongs_to :email_occurrence, inverse_of: :email_ip_occurrences
  belongs_to :ip_occurrence, inverse_of: :email_ip_occurrences
end
