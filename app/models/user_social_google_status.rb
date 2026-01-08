# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_google_statuses
#
#  id :string(255)      not null, primary key
#

class UserSocialGoogleStatus < PrincipalRecord
  include StringPrimaryKey

  has_many :user_social_googles, inverse_of: :user_social_google_status, dependent: :restrict_with_error

  # Status constants
  ACTIVE = "ACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"

  validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
end
