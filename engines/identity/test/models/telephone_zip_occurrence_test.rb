# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: telephone_zip_occurrences
# Database name: occurrence
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  telephone_occurrence_id :bigint           not null
#  zip_occurrence_id       :bigint           not null
#
# Indexes
#
#  idx_telephone_zip_occ_on_ids                          (telephone_occurrence_id,zip_occurrence_id) UNIQUE
#  index_telephone_zip_occurrences_on_zip_occurrence_id  (zip_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (telephone_occurrence_id => telephone_occurrences.id)
#  fk_rails_...  (zip_occurrence_id => zip_occurrences.id)
#

require "test_helper"

class TelephoneZipOccurrenceTest < ActiveSupport::TestCase
  fixtures :telephone_occurrences, :zip_occurrences

  test "associations" do
    record = TelephoneZipOccurrence.new(
      telephone_occurrence: telephone_occurrences(:one),
      zip_occurrence: zip_occurrences(:one),
    )

    assert record.save!
    assert_equal telephone_occurrences(:one), record.telephone_occurrence
    assert_equal zip_occurrences(:one), record.zip_occurrence
  end

  test "uniqueness validation" do
    TelephoneZipOccurrence.create!(
      telephone_occurrence: telephone_occurrences(:one),
      zip_occurrence: zip_occurrences(:one),
    )
    duplicate = TelephoneZipOccurrence.new(
      telephone_occurrence: telephone_occurrences(:one),
      zip_occurrence: zip_occurrences(:one),
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:telephone_occurrence_id]
  end
end
