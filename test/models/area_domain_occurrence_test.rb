# frozen_string_literal: true

# == Schema Information
#
# Table name: area_domain_occurrences
# Database name: occurrence
#
#  id                   :uuid             not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  area_occurrence_id   :uuid             not null
#  domain_occurrence_id :uuid             not null
#
# Indexes
#
#  index_area_domain_occurrences_on_area_occurrence_id    (area_occurrence_id)
#  index_area_domain_occurrences_on_domain_occurrence_id  (domain_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (area_occurrence_id => area_occurrences.id)
#  fk_rails_...  (domain_occurrence_id => domain_occurrences.id)
#

require "test_helper"

class AreaDomainOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
