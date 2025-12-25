# == Schema Information
#
# Table name: email_staff_occurrences
#
#  id                  :uuid             not null, primary key
#  email_occurrence_id :uuid             not null
#  staff_occurrence_id :uuid             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_email_staff_occurrences_on_email_occurrence_id  (email_occurrence_id)
#  index_email_staff_occurrences_on_staff_occurrence_id  (staff_occurrence_id)
#

class EmailStaffOccurrence < UniversalRecord
  belongs_to :email_occurrence
  belongs_to :staff_occurrence
end
