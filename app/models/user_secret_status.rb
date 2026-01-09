# frozen_string_literal: true

# == Schema Information
#
# Table name: user_secret_statuses
#
#  id :string(255)      not null, primary key
#

class UserSecretStatus < PrincipalRecord
  include StringPrimaryKey

  has_many :user_secrets, inverse_of: :user_secret_status, dependent: :restrict_with_error

  # Status constants
  ACTIVE = "ACTIVE"
  USED = "USED"
  EXPIRED = "EXPIRED"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
