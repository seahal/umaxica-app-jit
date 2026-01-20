# frozen_string_literal: true

# == Schema Information
#
# Table name: user_telephone_statuses
#
#  id :string(255)      default("UNVERIFIED"), not null, primary key
#

class UserTelephoneStatus < PrincipalRecord
  include StringPrimaryKey

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
  has_many :user_telephones, inverse_of: :user_telephone_status, dependent: :restrict_with_error
  validates :id, uniqueness: { case_sensitive: false }
end
