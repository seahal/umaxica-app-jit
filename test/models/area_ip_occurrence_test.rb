# == Schema Information
#
# Table name: area_ip_occurrences
#
#  id                 :uuid             not null, primary key
#  area_occurrence_id :uuid             not null
#  ip_occurrence_id   :uuid             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_area_ip_occurrences_on_area_occurrence_id  (area_occurrence_id)
#  index_area_ip_occurrences_on_ip_occurrence_id    (ip_occurrence_id)
#

require "test_helper"

class AreaIpOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
