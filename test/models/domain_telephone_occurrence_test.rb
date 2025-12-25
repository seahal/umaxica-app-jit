# == Schema Information
#
# Table name: domain_telephone_occurrences
#
#  id                      :uuid             not null, primary key
#  domain_occurrence_id    :uuid             not null
#  telephone_occurrence_id :uuid             not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_domain_telephone_occurrences_on_domain_occurrence_id     (domain_occurrence_id)
#  index_domain_telephone_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#

require "test_helper"

class DomainTelephoneOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
