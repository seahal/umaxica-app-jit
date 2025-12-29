# frozen_string_literal: true

# == Schema Information
#
# Table name: email_ip_occurrences
#
#  id                  :uuid             not null, primary key
#  email_occurrence_id :uuid             not null
#  ip_occurrence_id    :uuid             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_email_ip_occurrences_on_email_occurrence_id  (email_occurrence_id)
#  index_email_ip_occurrences_on_ip_occurrence_id     (ip_occurrence_id)
#

class EmailIpOccurrence < UniversalRecord
  self.implicit_order_column = :created_at

  belongs_to :email_occurrence, inverse_of: :email_ip_occurrences
  belongs_to :ip_occurrence, inverse_of: :email_ip_occurrences
end
