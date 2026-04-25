# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: area_telephone_occurrences
# Database name: occurrence
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  area_occurrence_id      :bigint           not null
#  telephone_occurrence_id :bigint           not null
#
# Indexes
#
#  idx_area_telephone_occ_on_ids                                (area_occurrence_id,telephone_occurrence_id) UNIQUE
#  index_area_telephone_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (area_occurrence_id => area_occurrences.id)
#  fk_rails_...  (telephone_occurrence_id => telephone_occurrences.id)
#

require "test_helper"

class AreaTelephoneOccurrenceTest < ActiveSupport::TestCase
  fixtures :area_occurrences, :telephone_occurrences

  test "associations" do
    record = AreaTelephoneOccurrence.new(
      area_occurrence: area_occurrences(:one),
      telephone_occurrence: telephone_occurrences(:one),
    )

    assert record.save!
    assert_equal area_occurrences(:one), record.area_occurrence
    assert_equal telephone_occurrences(:one), record.telephone_occurrence
  end

  test "uniqueness validation" do
    AreaTelephoneOccurrence.create!(
      area_occurrence: area_occurrences(:one),
      telephone_occurrence: telephone_occurrences(:one),
    )
    duplicate = AreaTelephoneOccurrence.new(
      area_occurrence: area_occurrences(:one),
      telephone_occurrence: telephone_occurrences(:one),
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:area_occurrence_id]
  end
end
