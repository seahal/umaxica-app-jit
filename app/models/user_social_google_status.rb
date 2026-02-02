# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_google_statuses
# Database name: principal
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_user_social_google_statuses_on_code  (code) UNIQUE
#
class UserSocialGoogleStatus < PrincipalRecord
  include CodeIdentifiable

  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
  has_many :user_social_googles, inverse_of: :user_social_google_status, dependent: :restrict_with_error
end
