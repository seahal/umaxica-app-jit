# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_passkey_statuses
# Database name: operator
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_staff_passkey_statuses_on_code  (code) UNIQUE
#

class StaffPasskeyStatus < OperatorRecord
  include CodeIdentifiable

  # Status constants
  ACTIVE = "ACTIVE"
  DISABLED = "DISABLED"
  DELETED = "DELETED"
  has_many :staff_passkeys, dependent: :restrict_with_error
  before_validation { self.id = id&.upcase }
end
