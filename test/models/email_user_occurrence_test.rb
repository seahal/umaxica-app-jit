# frozen_string_literal: true

# == Schema Information
#
# Table name: email_user_occurrences
# Database name: occurrence
#
#  id                  :uuid             not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  email_occurrence_id :uuid             not null
#  user_occurrence_id  :uuid             not null
#
# Indexes
#
#  index_email_user_occurrences_on_email_occurrence_id  (email_occurrence_id)
#  index_email_user_occurrences_on_user_occurrence_id   (user_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_occurrence_id => email_occurrences.id)
#  fk_rails_...  (user_occurrence_id => user_occurrences.id)
#

require "test_helper"

class EmailUserOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
