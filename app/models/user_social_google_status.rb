# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_google_statuses
# Database name: principal
#
#  id :string(255)      not null, primary key
#
# Indexes
#
#  index_user_identity_google_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

class UserSocialGoogleStatus < PrincipalRecord
  include StringPrimaryKey

  # Status constants
  ACTIVE = "ACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
  has_many :user_social_googles, inverse_of: :user_social_google_status, dependent: :restrict_with_error
  validates :id, uniqueness: { case_sensitive: false }
end
