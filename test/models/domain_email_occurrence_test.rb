# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_email_occurrences
# Database name: occurrence
#
#  id                   :uuid             not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  domain_occurrence_id :uuid             not null
#  email_occurrence_id  :uuid             not null
#
# Indexes
#
#  index_domain_email_occurrences_on_domain_occurrence_id  (domain_occurrence_id)
#  index_domain_email_occurrences_on_email_occurrence_id   (email_occurrence_id)
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
