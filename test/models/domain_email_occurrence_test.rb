# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_email_occurrences
# Database name: occurrence
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  domain_occurrence_id :bigint           not null
#  email_occurrence_id  :bigint           not null
#
# Indexes
#
#  idx_domain_email_occ_on_ids                            (domain_occurrence_id,email_occurrence_id) UNIQUE
#  index_domain_email_occurrences_on_email_occurrence_id  (email_occurrence_id)
#
# Foreign Keys
#
#  fk_rails_...  (domain_occurrence_id => domain_occurrences.id)
#  fk_rails_...  (email_occurrence_id => email_occurrences.id)
#

require "test_helper"

class DomainEmailOccurrenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
