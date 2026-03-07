# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: area_domain_occurrences
# Database name: occurrence
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  area_occurrence_id   :bigint           not null
#  domain_occurrence_id :bigint           not null
#
# Indexes
#
#  idx_area_domain_occ_on_ids                             (area_occurrence_id,domain_occurrence_id) UNIQUE
#  index_area_domain_occurrences_on_domain_occurrence_id  (domain_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (area_occurrence_id => area_occurrences.id)
#  fk_rails_...  (domain_occurrence_id => domain_occurrences.id)
#

require "test_helper"

class AreaDomainOccurrenceTest < ActiveSupport::TestCase
  fixtures :area_occurrences, :domain_occurrences

  test "associations" do
    record = AreaDomainOccurrence.new(
      area_occurrence: area_occurrences(:one),
      domain_occurrence: domain_occurrences(:one),
    )

    assert record.save!
    assert_equal area_occurrences(:one), record.area_occurrence
    assert_equal domain_occurrences(:one), record.domain_occurrence
  end

  test "uniqueness validation" do
    AreaDomainOccurrence.create!(
      area_occurrence: area_occurrences(:one),
      domain_occurrence: domain_occurrences(:one),
    )
    duplicate = AreaDomainOccurrence.new(
      area_occurrence: area_occurrences(:one),
      domain_occurrence: domain_occurrences(:one),
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:area_occurrence_id]
  end
end
