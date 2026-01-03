# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_email_occurrences
#
#  id                   :uuid             not null, primary key
#  domain_occurrence_id :uuid             not null
#  email_occurrence_id  :uuid             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_domain_email_occurrences_on_domain_occurrence_id  (domain_occurrence_id)
#  index_domain_email_occurrences_on_email_occurrence_id   (email_occurrence_id)
#

class DomainEmailOccurrence < UniversalRecord
  belongs_to :domain_occurrence, inverse_of: :domain_email_occurrences
  belongs_to :email_occurrence, inverse_of: :domain_email_occurrences
end
