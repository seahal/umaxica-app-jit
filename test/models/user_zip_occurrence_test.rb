# frozen_string_literal: true

# == Schema Information
#
# Table name: user_zip_occurrences
#
#  id                 :uuid             not null, primary key
#  user_occurrence_id :uuid             not null
#  zip_occurrence_id  :uuid             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_user_zip_occurrences_on_user_occurrence_id  (user_occurrence_id)
#  index_user_zip_occurrences_on_zip_occurrence_id   (zip_occurrence_id)
#

require "test_helper"

class UserZipOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
