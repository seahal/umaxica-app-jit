# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_ip_occurrences
# Database name: occurrence
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  domain_occurrence_id :bigint           not null
#  ip_occurrence_id     :bigint           not null
#
# Indexes
#
#  idx_domain_ip_occ_on_ids                         (domain_occurrence_id,ip_occurrence_id) UNIQUE
#  index_domain_ip_occurrences_on_ip_occurrence_id  (ip_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (domain_occurrence_id => domain_occurrences.id)
#  fk_rails_...  (ip_occurrence_id => ip_occurrences.id)
#

require "test_helper"

class DomainIpOccurrenceTest < ActiveSupport::TestCase
  test "class is defined" do
    assert_equal "DomainIpOccurrence", DomainIpOccurrence.name
  end
end
