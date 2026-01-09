# frozen_string_literal: true

# == Schema Information
#
# Table name: user_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class UserStatus < PrincipalRecord
  include StringPrimaryKey

  has_many :users,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :user_status

  # Status constants
  NEYO = "NEYO"
  ALIVE = "ALIVE"
  PRE_WITHDRAWAL_CONDITION = "PRE_WITHDRAWAL_CONDITION"
  WITHDRAWAL_COMPLETED = "WITHDRAWAL_COMPLETED"
end
