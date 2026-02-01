# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_zip_occurrences
# Database name: occurrence
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  domain_occurrence_id :bigint           not null
#  zip_occurrence_id    :bigint           not null
#
# Indexes
#
#  idx_domain_zip_occ_on_ids                             (domain_occurrence_id,zip_occurrence_id) UNIQUE
#  index_domain_zip_occurrences_on_domain_occurrence_id  (domain_occurrence_id)
#  index_domain_zip_occurrences_on_zip_occurrence_id     (zip_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (domain_occurrence_id => domain_occurrences.id)
#  fk_rails_...  (zip_occurrence_id => zip_occurrences.id)
#

require "test_helper"

class DomainZipOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
