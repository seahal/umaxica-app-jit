# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_email_occurrences
# Database name: occurrence
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  domain_occurrence_id :bigint           not null
#  email_occurrence_id  :bigint           not null
#
# Indexes
#
#  idx_domain_email_occ_on_ids                            (domain_occurrence_id,email_occurrence_id) UNIQUE
#  index_domain_email_occurrences_on_email_occurrence_id  (email_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (domain_occurrence_id => domain_occurrences.id)
#  fk_rails_...  (email_occurrence_id => email_occurrences.id)
#

require "test_helper"

class DomainEmailOccurrenceTest < ActiveSupport::TestCase
  fixtures :domain_occurrences

  test "associations" do
    domain = domain_occurrences(:one)
    email = EmailOccurrence.create!(body: "test@example.com")
    record = DomainEmailOccurrence.new(
      domain_occurrence: domain,
      email_occurrence: email,
    )

    assert record.save!
    assert_equal domain, record.domain_occurrence
    assert_equal email, record.email_occurrence
  end

  test "uniqueness validation" do
    domain = domain_occurrences(:one)
    email = EmailOccurrence.create!(body: "test2@example.com")
    DomainEmailOccurrence.create!(domain_occurrence: domain, email_occurrence: email)
    duplicate = DomainEmailOccurrence.new(domain_occurrence: domain, email_occurrence: email)

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:domain_occurrence_id]
  end
end
