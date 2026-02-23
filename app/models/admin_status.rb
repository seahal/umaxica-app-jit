# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_statuses
# Database name: operator
#
#  id :bigint           not null, primary key
#
class AdminStatus < OperatorRecord
  # Fixed IDs - do not modify these values
  ACTIVE = 1
  NEYO = 2

  has_many :admins,
           foreign_key: :status_id,
           inverse_of: :admin_status,
           dependent: :restrict_with_error
end
