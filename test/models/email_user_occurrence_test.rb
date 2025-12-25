# == Schema Information
#
# Table name: email_user_occurrences
#
#  id                  :uuid             not null, primary key
#  email_occurrence_id :uuid             not null
#  user_occurrence_id  :uuid             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_email_user_occurrences_on_email_occurrence_id  (email_occurrence_id)
#  index_email_user_occurrences_on_user_occurrence_id   (user_occurrence_id)
#

require "test_helper"

class EmailUserOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
