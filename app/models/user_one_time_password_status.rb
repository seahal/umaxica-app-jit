# frozen_string_literal: true

# == Schema Information
#
# Table name: user_one_time_password_statuses
#
#  id :string           not null, primary key
#

class UserOneTimePasswordStatus < PrincipalRecord
  include StringPrimaryKey

  has_many :user_one_time_passwords, dependent: :restrict_with_error,
                                     inverse_of: :user_one_time_password_status

  # Status constants
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"

  validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
end
