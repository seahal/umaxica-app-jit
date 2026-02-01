# frozen_string_literal: true

# == Schema Information
#
# Table name: division_statuses
# Database name: operator
#
#  id :string           not null, primary key
#
class DivisionStatus < OperatorRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :divisions, dependent: :restrict_with_error

  self.primary_key = "id"
end
