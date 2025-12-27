# frozen_string_literal: true

# == Schema Information
#
# Table name: area_domain_occurrences
#
#  id                   :uuid             not null, primary key
#  area_occurrence_id   :uuid             not null
#  domain_occurrence_id :uuid             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_area_domain_occurrences_on_area_occurrence_id    (area_occurrence_id)
#  index_area_domain_occurrences_on_domain_occurrence_id  (domain_occurrence_id)
#

require "test_helper"

class AreaDomainOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
