# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_apple_statuses
#
#  id :string(255)      not null, primary key
#

class UserSocialAppleStatus < PrincipalRecord
  include StringPrimaryKey

  # Status constants
  ACTIVE = "ACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
  has_many :user_social_apples, inverse_of: :user_social_apple_status, dependent: :restrict_with_error
  validates :id, uniqueness: { case_sensitive: false }
end
