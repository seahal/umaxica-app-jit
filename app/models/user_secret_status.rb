# frozen_string_literal: true

# == Schema Information
#
# Table name: user_secret_statuses
# Database name: principal
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_user_secret_statuses_on_code  (code) UNIQUE
#
class UserSecretStatus < PrincipalRecord
  include CodeIdentifiable

  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  USED = "USED"
  EXPIRED = "EXPIRED"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
  has_many :user_secrets, inverse_of: :user_secret_status, dependent: :restrict_with_error
end
