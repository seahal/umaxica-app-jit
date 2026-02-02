# frozen_string_literal: true

# == Schema Information
#
# Table name: user_one_time_password_statuses
# Database name: principal
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_user_one_time_password_statuses_on_code  (code) UNIQUE
#
class UserOneTimePasswordStatus < PrincipalRecord
  include CodeIdentifiable

  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
  has_many :user_one_time_passwords, dependent: :restrict_with_error,
                                     inverse_of: :user_one_time_password_status
end
