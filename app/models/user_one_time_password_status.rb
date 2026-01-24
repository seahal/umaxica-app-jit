# frozen_string_literal: true

# == Schema Information
#
# Table name: user_one_time_password_statuses
# Database name: principal
#
#  id :string           default("NEYO"), not null, primary key
#
# Indexes
#
#  index_user_identity_otp_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

class UserOneTimePasswordStatus < PrincipalRecord
  include StringPrimaryKey

  # Status constants
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
  has_many :user_one_time_passwords, dependent: :restrict_with_error,
                                     inverse_of: :user_one_time_password_status
  validates :id, uniqueness: { case_sensitive: false }
end
