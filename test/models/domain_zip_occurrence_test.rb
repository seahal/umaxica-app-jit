# == Schema Information
#
# Table name: domain_zip_occurrences
#
#  id                   :uuid             not null, primary key
#  domain_occurrence_id :uuid             not null
#  zip_occurrence_id    :uuid             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_domain_zip_occurrences_on_domain_occurrence_id  (domain_occurrence_id)
#  index_domain_zip_occurrences_on_zip_occurrence_id     (zip_occurrence_id)
#

require "test_helper"

class DomainZipOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
