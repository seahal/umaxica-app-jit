# frozen_string_literal: true

# == Schema Information
#
# Table name: user_secret_statuses
# Database name: principal
#
#  id :string(255)      not null, primary key
#
# Indexes
#
#  index_user_identity_secret_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

class UserSecretStatus < PrincipalRecord
  include StringPrimaryKey

  # Status constants
  ACTIVE = "ACTIVE"
  USED = "USED"
  EXPIRED = "EXPIRED"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
  has_many :user_secrets, inverse_of: :user_secret_status, dependent: :restrict_with_error
  validates :id, uniqueness: { case_sensitive: false }
end
