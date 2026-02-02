# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_apple_statuses
# Database name: principal
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_user_social_apple_statuses_on_code  (code) UNIQUE
#
class UserSocialAppleStatus < PrincipalRecord
  include CodeIdentifiable

  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
  has_many :user_social_apples, inverse_of: :user_social_apple_status, dependent: :restrict_with_error
end
