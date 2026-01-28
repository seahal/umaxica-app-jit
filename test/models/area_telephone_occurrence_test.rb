# frozen_string_literal: true

# == Schema Information
#
# Table name: area_telephone_occurrences
# Database name: occurrence
#
#  id                      :uuid             not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  area_occurrence_id      :uuid             not null
#  telephone_occurrence_id :uuid             not null
#
# Indexes
#
#  index_area_telephone_occurrences_on_area_occurrence_id       (area_occurrence_id)
#  index_area_telephone_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (area_occurrence_id => area_occurrences.id)
#  fk_rails_...  (telephone_occurrence_id => telephone_occurrences.id)
#

require "test_helper"

class AreaTelephoneOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
