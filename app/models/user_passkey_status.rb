# frozen_string_literal: true

# == Schema Information
#
# Table name: user_passkey_statuses
# Database name: principal
#
#  id :bigint           not null, primary key
#
class UserPasskeyStatus < PrincipalRecord
  ACTIVE = 1
  DISABLED = 2
  REVOKED = 3
  DELETED = 4
  NEYO = 5
  has_many :user_passkeys, dependent: :restrict_with_error
end
