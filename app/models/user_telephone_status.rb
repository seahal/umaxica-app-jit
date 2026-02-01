# frozen_string_literal: true

# == Schema Information
#
# Table name: user_telephone_statuses
# Database name: principal
#
#  id :integer          not null, primary key
#
class UserTelephoneStatus < PrincipalRecord
  include CodeIdentifiable

  NEYO = "NEYO"
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
  has_many :user_telephones, inverse_of: :user_telephone_status, dependent: :restrict_with_error
end
