# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: email_zip_occurrences
# Database name: occurrence
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  email_occurrence_id :bigint           not null
#  zip_occurrence_id   :bigint           not null
#
# Indexes
#
#  idx_email_zip_occ_on_ids                          (email_occurrence_id,zip_occurrence_id) UNIQUE
#  index_email_zip_occurrences_on_zip_occurrence_id  (zip_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_occurrence_id => email_occurrences.id)
#  fk_rails_...  (zip_occurrence_id => zip_occurrences.id)
#

require "test_helper"

class EmailZipOccurrenceTest < ActiveSupport::TestCase
  fixtures :zip_occurrences

  test "associations" do
    email = EmailOccurrence.create!(body: "test@example.com")
    record = EmailZipOccurrence.new(
      email_occurrence: email,
      zip_occurrence: zip_occurrences(:one),
    )

    assert record.save!
    assert_equal email, record.email_occurrence
    assert_equal zip_occurrences(:one), record.zip_occurrence
  end

  test "uniqueness validation" do
    email = EmailOccurrence.create!(body: "test2@example.com")
    EmailZipOccurrence.create!(
      email_occurrence: email,
      zip_occurrence: zip_occurrences(:one),
    )
    duplicate = EmailZipOccurrence.new(
      email_occurrence: email,
      zip_occurrence: zip_occurrences(:one),
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:email_occurrence_id]
  end
end
