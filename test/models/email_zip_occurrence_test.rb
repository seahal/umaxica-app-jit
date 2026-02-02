# frozen_string_literal: true

# == Schema Information
#
# Table name: email_zip_occurrences
# Database name: occurrence
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  email_occurrence_id :bigint           not null
#  zip_occurrence_id   :bigint           not null
#
# Indexes
#
#  idx_email_zip_occ_on_ids                          (email_occurrence_id,zip_occurrence_id) UNIQUE
#  index_email_zip_occurrences_on_zip_occurrence_id  (zip_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_occurrence_id => email_occurrences.id)
#  fk_rails_...  (zip_occurrence_id => zip_occurrences.id)
#

require "test_helper"

class EmailZipOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
