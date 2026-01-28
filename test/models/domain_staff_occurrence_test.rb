# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_staff_occurrences
# Database name: occurrence
#
#  id                   :uuid             not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  domain_occurrence_id :uuid             not null
#  staff_occurrence_id  :uuid             not null
#
# Indexes
#
#  index_domain_staff_occurrences_on_domain_occurrence_id  (domain_occurrence_id)
#  index_domain_staff_occurrences_on_staff_occurrence_id   (staff_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (domain_occurrence_id => domain_occurrences.id)
#  fk_rails_...  (staff_occurrence_id => staff_occurrences.id)
#

require "test_helper"

class DomainStaffOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
