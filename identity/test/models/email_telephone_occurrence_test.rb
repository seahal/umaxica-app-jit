# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: email_telephone_occurrences
# Database name: occurrence
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  email_occurrence_id     :bigint           not null
#  telephone_occurrence_id :bigint           not null
#
# Indexes
#
#  idx_email_telephone_occ_on_ids                                (email_occurrence_id,telephone_occurrence_id) UNIQUE
#  index_email_telephone_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_occurrence_id => email_occurrences.id)
#  fk_rails_...  (telephone_occurrence_id => telephone_occurrences.id)
#

require "test_helper"

class EmailTelephoneOccurrenceTest < ActiveSupport::TestCase
  fixtures :telephone_occurrences

  test "associations" do
    email = EmailOccurrence.create!(body: "test@example.com")
    record = EmailTelephoneOccurrence.new(
      email_occurrence: email,
      telephone_occurrence: telephone_occurrences(:one),
    )

    assert record.save!
    assert_equal email, record.email_occurrence
    assert_equal telephone_occurrences(:one), record.telephone_occurrence
  end

  test "uniqueness validation" do
    email = EmailOccurrence.create!(body: "test2@example.com")
    EmailTelephoneOccurrence.create!(
      email_occurrence: email,
      telephone_occurrence: telephone_occurrences(:one),
    )
    duplicate = EmailTelephoneOccurrence.new(
      email_occurrence: email,
      telephone_occurrence: telephone_occurrences(:one),
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:email_occurrence_id]
  end
end
