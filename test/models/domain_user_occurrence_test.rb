# == Schema Information
#
# Table name: domain_user_occurrences
#
#  id                   :uuid             not null, primary key
#  domain_occurrence_id :uuid             not null
#  user_occurrence_id   :uuid             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_domain_user_occurrences_on_domain_occurrence_id  (domain_occurrence_id)
#  index_domain_user_occurrences_on_user_occurrence_id    (user_occurrence_id)
#

require "test_helper"

class DomainUserOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
