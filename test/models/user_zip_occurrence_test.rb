# frozen_string_literal: true

# == Schema Information
#
# Table name: user_zip_occurrences
# Database name: occurrence
#
#  id                 :uuid             not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_occurrence_id :uuid             not null
#  zip_occurrence_id  :uuid             not null
#
# Indexes
#
#  index_user_zip_occurrences_on_user_occurrence_id  (user_occurrence_id)
#  index_user_zip_occurrences_on_zip_occurrence_id   (zip_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_occurrence_id => user_occurrences.id)
#  fk_rails_...  (zip_occurrence_id => zip_occurrences.id)
#

require "test_helper"

class UserZipOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
