# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_ip_occurrences
#
#  id                   :uuid             not null, primary key
#  domain_occurrence_id :uuid             not null
#  ip_occurrence_id     :uuid             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_domain_ip_occurrences_on_domain_occurrence_id  (domain_occurrence_id)
#  index_domain_ip_occurrences_on_ip_occurrence_id      (ip_occurrence_id)
#

class DomainIpOccurrence < UniversalRecord
  self.implicit_order_column = :created_at

  belongs_to :domain_occurrence
  belongs_to :ip_occurrence
end
