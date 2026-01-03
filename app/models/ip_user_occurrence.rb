# frozen_string_literal: true

# == Schema Information
#
# Table name: ip_user_occurrences
#
#  id                 :uuid             not null, primary key
#  ip_occurrence_id   :uuid             not null
#  user_occurrence_id :uuid             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_ip_user_occurrences_on_ip_occurrence_id    (ip_occurrence_id)
#  index_ip_user_occurrences_on_user_occurrence_id  (user_occurrence_id)
#

class IpUserOccurrence < UniversalRecord
  belongs_to :ip_occurrence, inverse_of: :ip_user_occurrences
  belongs_to :user_occurrence, inverse_of: :ip_user_occurrences
end
