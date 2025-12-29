# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_user_occurrences
#
#  id                   :uuid             not null, primary key
#  domain_occurrence_id :uuid             not null
#  user_occurrence_id   :uuid             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_domain_user_occurrences_on_domain_occurrence_id  (domain_occurrence_id)
#  index_domain_user_occurrences_on_user_occurrence_id    (user_occurrence_id)
#

class DomainUserOccurrence < UniversalRecord
  self.implicit_order_column = :created_at

  belongs_to :domain_occurrence, inverse_of: :domain_user_occurrences
  belongs_to :user_occurrence, inverse_of: :domain_user_occurrences
end
