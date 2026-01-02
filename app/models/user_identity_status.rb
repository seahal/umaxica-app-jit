# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class UserIdentityStatus < IdentitiesRecord
  include UppercaseId

  has_many :users,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :user_identity_status

  # Status constants
  NEYO = "NEYO"
  ALIVE = "ALIVE"
  PRE_WITHDRAWAL_CONDITION = "PRE_WITHDRAWAL_CONDITION"
  WITHDRAWAL_COMPLETED = "WITHDRAWAL_COMPLETED"

  validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
end
