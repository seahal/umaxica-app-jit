# frozen_string_literal: true

# == Schema Information
#
# Table name: ip_staff_occurrences
# Database name: occurrence
#
#  id                  :uuid             not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  ip_occurrence_id    :uuid             not null
#  staff_occurrence_id :uuid             not null
#
# Indexes
#
#  index_ip_staff_occurrences_on_ip_occurrence_id     (ip_occurrence_id)
#  index_ip_staff_occurrences_on_staff_occurrence_id  (staff_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (ip_occurrence_id => ip_occurrences.id)
#  fk_rails_...  (staff_occurrence_id => staff_occurrences.id)
#

class IpStaffOccurrence < OccurrenceRecord
  belongs_to :ip_occurrence, inverse_of: :ip_staff_occurrences
  belongs_to :staff_occurrence, inverse_of: :ip_staff_occurrences
end
