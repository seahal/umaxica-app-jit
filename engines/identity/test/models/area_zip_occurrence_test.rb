# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: area_zip_occurrences
# Database name: occurrence
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  area_occurrence_id :bigint           not null
#  zip_occurrence_id  :bigint           not null
#
# Indexes
#
#  idx_area_zip_occ_on_ids                          (area_occurrence_id,zip_occurrence_id) UNIQUE
#  index_area_zip_occurrences_on_zip_occurrence_id  (zip_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (area_occurrence_id => area_occurrences.id)
#  fk_rails_...  (zip_occurrence_id => zip_occurrences.id)
#

require "test_helper"

class AreaZipOccurrenceTest < ActiveSupport::TestCase
  fixtures :area_occurrences, :zip_occurrences

  test "associations" do
    record = AreaZipOccurrence.new(
      area_occurrence: area_occurrences(:one),
      zip_occurrence: zip_occurrences(:one),
    )

    assert record.save!
    assert_equal area_occurrences(:one), record.area_occurrence
    assert_equal zip_occurrences(:one), record.zip_occurrence
  end

  test "uniqueness validation" do
    AreaZipOccurrence.create!(
      area_occurrence: area_occurrences(:one),
      zip_occurrence: zip_occurrences(:one),
    )
    duplicate = AreaZipOccurrence.new(
      area_occurrence: area_occurrences(:one),
      zip_occurrence: zip_occurrences(:one),
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:area_occurrence_id]
  end
end
