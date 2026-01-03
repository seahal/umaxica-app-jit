# frozen_string_literal: true

# == Schema Information
#
# Table name: ip_telephone_occurrences
#
#  id                      :uuid             not null, primary key
#  ip_occurrence_id        :uuid             not null
#  telephone_occurrence_id :uuid             not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_ip_telephone_occurrences_on_ip_occurrence_id         (ip_occurrence_id)
#  index_ip_telephone_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#

class IpTelephoneOccurrence < UniversalRecord
  belongs_to :ip_occurrence, inverse_of: :ip_telephone_occurrences
  belongs_to :telephone_occurrence, inverse_of: :ip_telephone_occurrences
end
