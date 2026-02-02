# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_telephone_occurrences
# Database name: occurrence
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  domain_occurrence_id    :bigint           not null
#  telephone_occurrence_id :bigint           not null
#
# Indexes
#
#  idx_domain_telephone_occ_on_ids                                (domain_occurrence_id,telephone_occurrence_id) UNIQUE
#  index_domain_telephone_occurrences_on_telephone_occurrence_id  (telephone_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (domain_occurrence_id => domain_occurrences.id)
#  fk_rails_...  (telephone_occurrence_id => telephone_occurrences.id)
#

require "test_helper"

class DomainTelephoneOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
