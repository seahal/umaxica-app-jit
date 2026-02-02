# frozen_string_literal: true

# == Schema Information
#
# Table name: division_statuses
# Database name: operator
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_division_statuses_on_code  (code) UNIQUE
#
class DivisionStatus < OperatorRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :divisions, dependent: :restrict_with_error

  self.primary_key = "id"
end
