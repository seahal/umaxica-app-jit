# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_user_occurrences
# Database name: occurrence
#
#  id                   :uuid             not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  domain_occurrence_id :uuid             not null
#  user_occurrence_id   :uuid             not null
#
# Indexes
#
#  index_domain_user_occurrences_on_domain_occurrence_id  (domain_occurrence_id)
#  index_domain_user_occurrences_on_user_occurrence_id    (user_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (domain_occurrence_id => domain_occurrences.id)
#  fk_rails_...  (user_occurrence_id => user_occurrences.id)
#

require "test_helper"

class DomainUserOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
