# frozen_string_literal: true

# == Schema Information
#
# Table name: user_passkey_statuses
# Database name: principal
#
#  id :string(255)      not null, primary key
#
# Indexes
#
#  index_user_identity_passkey_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

class UserPasskeyStatus < PrincipalRecord
  include StringPrimaryKey

  # Status constants
  ACTIVE = "ACTIVE"
  DISABLED = "DISABLED"
  DELETED = "DELETED"
  has_many :user_passkeys, dependent: :restrict_with_error

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Z0-9_]+\z/ }
  before_validation { self.id = id&.upcase }
end
