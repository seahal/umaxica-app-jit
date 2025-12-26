# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_passkey_statuses
#
#  id :string(255)      not null, primary key
#

class UserIdentityPasskeyStatus < IdentitiesRecord
  include UppercaseId

  has_many :user_identity_passkeys, dependent: :restrict_with_error

  before_validation { self.id = id&.upcase }
  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Z0-9_]+\z/ }

  # Status constants
  ACTIVE = "ACTIVE"
  DISABLED = "DISABLED"
  DELETED = "DELETED"
end
