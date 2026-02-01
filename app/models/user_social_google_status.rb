# frozen_string_literal: true

# == Schema Information
#
# Table name: user_social_google_statuses
# Database name: principal
#
#  id :integer          not null, primary key
#
class UserSocialGoogleStatus < PrincipalRecord
  include CodeIdentifiable

  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
  has_many :user_social_googles, inverse_of: :user_social_google_status, dependent: :restrict_with_error
end
