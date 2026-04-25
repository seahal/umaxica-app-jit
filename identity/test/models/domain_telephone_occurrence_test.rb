# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_telephone_occurrences
# Database name: occurrence
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  domain_occurrence_id    :bigint           not null
#  telephone_occurrence_id :bigint           not null
#
# Indexes
#
#  idx_domain_telephone_occ_on_ids                                (domain_occurrence_id,telephone_occurrence_id) UNIQUE
#  index_domain_telephone_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (domain_occurrence_id => domain_occurrences.id)
#  fk_rails_...  (telephone_occurrence_id => telephone_occurrences.id)
#

require "test_helper"

class DomainTelephoneOccurrenceTest < ActiveSupport::TestCase
  fixtures :domain_occurrences, :telephone_occurrences

  test "associations" do
    record = DomainTelephoneOccurrence.new(
      domain_occurrence: domain_occurrences(:one),
      telephone_occurrence: telephone_occurrences(:one),
    )

    assert record.save!
    assert_equal domain_occurrences(:one), record.domain_occurrence
    assert_equal telephone_occurrences(:one), record.telephone_occurrence
  end

  test "uniqueness validation" do
    DomainTelephoneOccurrence.create!(
      domain_occurrence: domain_occurrences(:one),
      telephone_occurrence: telephone_occurrences(:one),
    )
    duplicate = DomainTelephoneOccurrence.new(
      domain_occurrence: domain_occurrences(:one),
      telephone_occurrence: telephone_occurrences(:one),
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:domain_occurrence_id]
  end
end
