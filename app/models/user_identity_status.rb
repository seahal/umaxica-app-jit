# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class UserIdentityStatus < IdentitiesRecord
  include UppercaseId

  has_many :users, dependent: :restrict_with_error

  # Status constants
  NEYO = "NEYO"
  ALIVE = "ALIVE"
  PRE_WITHDRAWAL_CONDITION = "PRE_WITHDRAWAL_CONDITION"
  WITHDRAWAL_COMPLETED = "WITHDRAWAL_COMPLETED"
end
