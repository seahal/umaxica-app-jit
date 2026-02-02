# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_secret_statuses
# Database name: operator
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_staff_secret_statuses_on_code  (code) UNIQUE
#

class StaffSecretStatus < OperatorRecord
  include CodeIdentifiable

  # Status constants
  ACTIVE = "ACTIVE"
  USED = "USED"
  EXPIRED = "EXPIRED"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
  has_many :staff_secrets, inverse_of: :staff_secret_status, dependent: :restrict_with_error
end
