# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_secret_statuses
#
#  id :string(255)      not null, primary key
#

class StaffSecretStatus < OperatorRecord
  include StringPrimaryKey

  validates :id, uniqueness: { case_sensitive: false }

  has_many :staff_secrets, inverse_of: :staff_secret_status, dependent: :restrict_with_error

  # Status constants
  ACTIVE = "ACTIVE"
  USED = "USED"
  EXPIRED = "EXPIRED"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
