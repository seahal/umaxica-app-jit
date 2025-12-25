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
  self.implicit_order_column = :created_at

  belongs_to :domain_occurrence
  belongs_to :email_occurrence
end
