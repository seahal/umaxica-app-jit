# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: email_user_occurrences
# Database name: occurrence
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  email_occurrence_id :bigint           not null
#  user_occurrence_id  :bigint           not null
#
# Indexes
#
#  idx_email_user_occ_on_ids                           (email_occurrence_id,user_occurrence_id) UNIQUE
#  index_email_user_occurrences_on_user_occurrence_id  (user_occurrence_id)
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
