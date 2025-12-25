# == Schema Information
#
# Table name: ip_zip_occurrences
#
#  id                :uuid             not null, primary key
#  ip_occurrence_id  :uuid             not null
#  zip_occurrence_id :uuid             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_ip_zip_occurrences_on_ip_occurrence_id   (ip_occurrence_id)
#  index_ip_zip_occurrences_on_zip_occurrence_id  (zip_occurrence_id)
#

require "test_helper"

class IpZipOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
