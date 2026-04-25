# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: area_email_occurrences
# Database name: occurrence
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  area_occurrence_id  :bigint           not null
#  email_occurrence_id :bigint           not null
#
# Indexes
#
#  idx_area_email_occ_on_ids                            (area_occurrence_id,email_occurrence_id) UNIQUE
#  index_area_email_occurrences_on_email_occurrence_id  (email_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (area_occurrence_id => area_occurrences.id)
#  fk_rails_...  (email_occurrence_id => email_occurrences.id)
#

require "test_helper"

class AreaEmailOccurrenceTest < ActiveSupport::TestCase
  fixtures :area_occurrences

  test "associations" do
    area = area_occurrences(:one)
    email = EmailOccurrence.create!(body: "test@example.com")
    record = AreaEmailOccurrence.new(
      area_occurrence: area,
      email_occurrence: email,
    )

    assert record.save!
    assert_equal area, record.area_occurrence
    assert_equal email, record.email_occurrence
  end

  test "uniqueness validation" do
    area = area_occurrences(:one)
    email = EmailOccurrence.create!(body: "test2@example.com")
    AreaEmailOccurrence.create!(area_occurrence: area, email_occurrence: email)
    duplicate = AreaEmailOccurrence.new(area_occurrence: area, email_occurrence: email)

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:area_occurrence_id]
  end
end
