# frozen_string_literal: true

# == Schema Information
#
# Table name: email_telephone_occurrences
#
#  id                      :uuid             not null, primary key
#  email_occurrence_id     :uuid             not null
#  telephone_occurrence_id :uuid             not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_email_telephone_occurrences_on_email_occurrence_id      (email_occurrence_id)
#  index_email_telephone_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#

require "test_helper"

class EmailTelephoneOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
