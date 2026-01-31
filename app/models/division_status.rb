# frozen_string_literal: true

# == Schema Information
#
# Table name: division_statuses
# Database name: operator
#
#  id :string(255)      not null, primary key
#
# Indexes
#
#  index_division_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#
class DivisionStatus < OperatorRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :divisions, dependent: :restrict_with_error
  validates :id, uniqueness: { case_sensitive: false }

  self.primary_key = "id"
end
