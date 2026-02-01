# == Schema Information
#
# Table name: staff_one_time_password_statuses
# Database name: operator
#
#  id :string           not null, primary key
#

# frozen_string_literal: true

class StaffOneTimePasswordStatus < OperatorRecord
  include CodeIdentifiable

  # Status constants
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"

  has_many :staff_one_time_passwords, dependent: :restrict_with_error
                 format: { with: /\A[A-Z0-9_]+\z/ }
  before_validation { self.id = id&.upcase }
end
