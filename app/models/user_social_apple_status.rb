# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_apple_statuses
#
#  id :string(255)      not null, primary key
#

class UserSocialAppleStatus < PrincipalRecord
  include UppercaseId

  has_many :user_social_apples, dependent: :restrict_with_error

  # Status constants
  ACTIVE = "ACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"

  validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
end
