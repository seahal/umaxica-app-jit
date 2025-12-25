# == Schema Information
#
# Table name: domain_staff_occurrences
#
#  id                   :uuid             not null, primary key
#  domain_occurrence_id :uuid             not null
#  staff_occurrence_id  :uuid             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_domain_staff_occurrences_on_domain_occurrence_id  (domain_occurrence_id)
#  index_domain_staff_occurrences_on_staff_occurrence_id   (staff_occurrence_id)
#

require "test_helper"

class DomainStaffOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
