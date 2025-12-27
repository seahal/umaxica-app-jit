# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_social_google_statuses
#
#  id :string(255)      not null, primary key
#

class UserIdentitySocialGoogleStatus < IdentitiesRecord
  include UppercaseId

  has_many :user_identity_social_googles, dependent: :restrict_with_error

  # Status constants
  ACTIVE = "ACTIVE"
  REVOKED = "REVOKED"
  DELETED = "DELETED"
end
