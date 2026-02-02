# frozen_string_literal: true

# == Schema Information
#
# Table name: user_passkey_statuses
# Database name: principal
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_user_passkey_statuses_on_code  (code) UNIQUE
#
class UserPasskeyStatus < PrincipalRecord
  include CodeIdentifiable

  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  DISABLED = "DISABLED"
  DELETED = "DELETED"
  has_many :user_passkeys, dependent: :restrict_with_error
end
