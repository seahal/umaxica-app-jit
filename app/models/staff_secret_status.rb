# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_secret_statuses
# Database name: operator
#
#  id :string(255)      not null, primary key
#
# Indexes
#
#  index_staff_identity_secret_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

class StaffSecretStatus < OperatorRecord
  include StringPrimaryKey

  # Status constants
  ACTIVE = "ACTIVE"
  USED = "USED"
  EXPIRED = "EXPIRED"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
  has_many :staff_secrets, inverse_of: :staff_secret_status, dependent: :restrict_with_error
  validates :id, uniqueness: { case_sensitive: false }
end
