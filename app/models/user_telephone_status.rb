# frozen_string_literal: true

# == Schema Information
#
# Table name: user_telephone_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

class UserTelephoneStatus < PrincipalRecord
  include StringPrimaryKey

  validates :id, uniqueness: { case_sensitive: false }

  has_many :user_telephones, inverse_of: :user_telephone_status, dependent: :restrict_with_error

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
end
