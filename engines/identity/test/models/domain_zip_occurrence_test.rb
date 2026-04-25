# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_zip_occurrences
# Database name: occurrence
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  domain_occurrence_id :bigint           not null
#  zip_occurrence_id    :bigint           not null
#
# Indexes
#
#  idx_domain_zip_occ_on_ids                          (domain_occurrence_id,zip_occurrence_id) UNIQUE
#  index_domain_zip_occurrences_on_zip_occurrence_id  (zip_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (domain_occurrence_id => domain_occurrences.id)
#  fk_rails_...  (zip_occurrence_id => zip_occurrences.id)
#

require "test_helper"

class DomainZipOccurrenceTest < ActiveSupport::TestCase
  fixtures :domain_occurrences, :zip_occurrences

  test "associations" do
    record = DomainZipOccurrence.new(
      domain_occurrence: domain_occurrences(:one),
      zip_occurrence: zip_occurrences(:one),
    )

    assert record.save!
    assert_equal domain_occurrences(:one), record.domain_occurrence
    assert_equal zip_occurrences(:one), record.zip_occurrence
  end

  test "uniqueness validation" do
    DomainZipOccurrence.create!(
      domain_occurrence: domain_occurrences(:one),
      zip_occurrence: zip_occurrences(:one),
    )
    duplicate = DomainZipOccurrence.new(
      domain_occurrence: domain_occurrences(:one),
      zip_occurrence: zip_occurrences(:one),
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:domain_occurrence_id]
  end
end
